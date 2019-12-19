//
//  AppDelegate.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 24/08/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord
import Fabric
import Crashlytics
import StoreKit
import Alamofire
import SDWebImage
import UserNotifications
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var checkedLastPushRequestDateThisLaunch : Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SKPaymentQueue.default().add(self)
        Fabric.with([Crashlytics.self])
        MagicalRecord.setLoggingLevel(.error)
        MagicalRecord.setupAutoMigratingCoreDataStack()
        ModelManager.loadDBFromFileIfNeeded()
        StoreHelper.sharedInstance.requestFullVersionProductsInfo(nil)
        
        let memoryForImages = ProcessInfo.processInfo.physicalMemory / 4 / 4
        SDImageCache.shared().maxMemoryCost = UInt(memoryForImages)
        
        LilWorldAPIClient.getProductIDs { productsIDs -> Void in
            StoreHelper.sharedInstance.requestProductsInfo(productsIDs, completion: nil)
        }
        
        appAppearanceSetup()
		photoLibraryAvailabilityCheck()
        
        AnalyticsEngine.initializeWithFlurryTrackerID("6NMZHNK3Q5BHG553NYFF")
        
        KulaAppirater.sharedInstance.usesUntilPrompt = 6
        KulaAppirater.sharedInstance.appID = "1037388546"
        
        return true
    }
    
    fileprivate func appAppearanceSetup() {
        UITextView.appearance().tintColor = UIColor(red:0.54, green:0.62, blue:0.72, alpha:1.00)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        LilWorldAPIClient.updateSectionsIfNeeded()
        UIApplication.shared.applicationIconBadgeNumber = 0
        delay(2.5) {
            self.requestNotificationsAuthorizationIfNeeded()
        }
        KulaAppirater.sharedInstance.appLaunched()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushManager.registerDeviceToken(deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: ""))
    }
		
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SDImageCache.shared().clearMemory()
    }
    
    func registerApplicationForRemoteNotifications(_ application : UIApplication) {
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                if granted {
                    application.registerForRemoteNotifications()
                }
            })
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge],
                categories: nil))
        }
    }

    func requestNotificationsAuthorizationIfNeeded() {
        
        let application = UIApplication.shared
        
        let lastRequestDateKey = "LastPushRequestDate"
        
        //checks
        if checkedLastPushRequestDateThisLaunch {
            return
        }
        
        if application.isRegisteredForRemoteNotifications {
            return
        }
        let lastRequestDate = UserDefaults.standard.double(forKey: lastRequestDateKey)
        if lastRequestDate != 0 {
            let currentDate = Date().timeIntervalSinceReferenceDate
            if (currentDate - lastRequestDate) / (24 * 60 * 60) <= 7 {
                checkedLastPushRequestDateThisLaunch = true
                return
            }
        }
        let popupViewController = PopupViewController(title:localizedStringForKey("pushrequest_alert_title"), message:localizedStringForKey("pushrequest_alert_message"))
        popupViewController.setLeftButtonTitle(localizedStringForKey("pushrequest_alert_nobutton_title").uppercased()) {
            UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: lastRequestDateKey)
            UserDefaults.standard.synchronize()
            popupViewController.dismiss(animated: true, completion: nil)
        }
        
        popupViewController.setRightButtonTitle(localizedStringForKey("pushrequest_alert_yesbutton_title").uppercased()) { (textFieldText, textViewText) in
            self.registerApplicationForRemoteNotifications(application)
            self.checkedLastPushRequestDateThisLaunch = true
            popupViewController.dismiss(animated: true, completion: nil)
        }

        let formSheet = popupViewController.formSheetViewController()
        window?.rootViewController?.present(formSheet, animated: true, completion: nil)
    }
    
    func localizedStringForKey(_ key:String) -> String {
        return NSLocalizedString(key, comment: "")
    }
	
	//MARK:- PHOTO LIBRARY ACCESS CHECK
	func photoLibraryAvailabilityCheck()
	{
		if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized
		{
			PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
		}
	}
	func requestAuthorizationHandler(status: PHAuthorizationStatus)
	{
		if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized
		{
			//			alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
		}
	}
}

extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if (transaction.transactionState == .failed) {
                queue.finishTransaction(transaction)
                print("Failed")
            }
            else if (transaction.transactionState == .purchased) {
                print("Purchased")
                let productId = transaction.payment.productIdentifier
                StoreHelper.sharedInstance.addProductId(productId)
                queue.finishTransaction(transaction)
            }
        }
    }
}

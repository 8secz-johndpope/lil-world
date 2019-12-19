//
//  KulaAppirater.swift
//  KulaTechEngine
//
//  Created by Aleksandr Novikov on 17/05/16.
//
//

import UIKit
import MZFormSheetPresentationController

struct NSDefaultsNumber<Type> {
    
    init(key : String) {
        self.key = key
    }
    
    let key : String
    var internalNumber : NSNumber {
        get {
            let object = UserDefaults.standard.object(forKey: key) ?? NSNumber(value: 0 as Int32)
            return object as! NSNumber
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    mutating func setValue(_ value : Type) {
        guard let value = value as? NSNumber else {
            return
        }
        internalNumber = value
    }
    
    func value() -> Type {
        return internalNumber as! Type
    }
}

@objc open class KulaAppirater: NSObject {
    
    let templateReviewURLiOS7 =  "itms-apps://itunes.apple.com/app/id%@"
    let templateReviewURLiOS8 = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    
    open static let sharedInstance = KulaAppirater()
    
    var useCount = NSDefaultsNumber<Int>(key: "KulaAppirater.useCount")
    var firstUseDate = NSDefaultsNumber<Double>(key: "KulaAppirater.firstUseDate")
    var userRatedCurrentVersion = NSDefaultsNumber<Bool>(key: "KulaAppirater.userRatedCurrentVersion")
    var userDeclinedToRate = NSDefaultsNumber<Bool>(key: "KulaAppirater.userDeclinedToRate")
    var rateLaterDate = NSDefaultsNumber<Double>(key : "KulaAppirater.RateLaterDate")
    
    var currentVersionString : String? {
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "KulaAppirater.currentVersion")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.object(forKey: "KulaAppirater.currentVersion") as? String
        }
    }
    
    open var showsReviewPopup : Bool = false
    
    open var appID : String?
    
    open var daysUntilPrompt : Int = 3
    open var usesUntilPrompt : Int = 6
    open var daysUntilReminding : Int = 7
    
    open func appLaunched() {
        
        checkVersionChange()
        
        let useCountPlusOne = useCount.value() + 1
        useCount.setValue(useCountPlusOne)
        UserDefaults.standard.synchronize()
    }
    
    func checkVersionChange() {
        
        let appVersionString = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        if currentVersionString == nil {
            resetTrackingSettings()
            currentVersionString = appVersionString
        }
        if let currentVersionString = currentVersionString, let appVersionString = appVersionString, currentVersionString != appVersionString {
            resetTrackingSettings()
            self.currentVersionString = appVersionString
        }
    }
    
    func resetTrackingSettings() {
        useCount.setValue(0)
        rateLaterDate.setValue(0)
        firstUseDate.setValue(Date.timeIntervalSinceReferenceDate)
        userRatedCurrentVersion.setValue(false)
        userDeclinedToRate.setValue(false)
        UserDefaults.standard.synchronize()
    }
    
    open func showAlertIfNeeded() {
        
        guard alertIsAppropriate() else {
            return
        }
        
        let currentDate = Date.timeIntervalSinceReferenceDate
        
        if rateLaterDate.value() != 0 {
            let daysSinceRateLaterDate = (currentDate - rateLaterDate.value()) / (24 * 60 * 60)
            if Int(daysSinceRateLaterDate) >= daysUntilReminding {
                showAlert()
            }
            return
        }
    
        let daysSinceFirstUseDate = (currentDate - firstUseDate.value()) / (24 * 60 * 60)
        if Int(daysSinceFirstUseDate) >= daysUntilPrompt {
            showAlert()
            return
        }
        
        let useCountValue = useCount.value()
        if useCountValue >= usesUntilPrompt {
            showAlert()
            return
        }
    }
    
    func showAlert() {
        showPopup(popupViewController())
    }
    
    open func showReviewAlert() {
        showPopup(reviewPopupViewController())
    }
    
    func showPopup(_ viewController: PopupViewController) {
        let popupFormSheet = viewController.formSheetViewController()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(popupFormSheet, animated: true, completion: nil)
    }
    
    func popupViewController() -> PopupViewController {
        let popupViewController = PopupViewController(title: localizationStringForKey("appirater_alert_title"), message: localizationStringForKey("appirater_alert_message"))
        
        popupViewController.setLeftButtonTitle(localizationStringForKey("appirater_alert_nobutton_title").uppercased()) {
            popupViewController.dismiss(animated: true, completion: {
                if self.showsReviewPopup {
                    self.showReviewAlert()
                } else {
                    self.updateRemindLaterDate()
                }
            })
        }
        
        popupViewController.setRightButtonTitle(localizationStringForKey("appirater_alert_yesbutton_title").uppercased()) {_,_ in
            self.userRatedCurrentVersion.setValue(true)
            UserDefaults.standard.synchronize()
            if let appID = self.appID {
                
                let reviewURL = String(format: self.templateReviewURLiOS8, appID)
                if let url = URL(string: reviewURL) {
                    UIApplication.shared.openURL(url)
                }
                let popupParent = popupViewController.presentingViewController
                popupViewController.dismiss(animated: true, completion:nil)
            }
        }
        
        return popupViewController
    }
    
    func updateRemindLaterDate() {
        rateLaterDate.setValue(Date.timeIntervalSinceReferenceDate)
        UserDefaults.standard.synchronize()
    }
    
    open func reviewPopupViewController() -> PopupViewController {
        let reviewPopupViewController = PopupViewController(title: localizationStringForKey("appirater_review_alert_title"), message: localizationStringForKey("appirater_review_alert_message"), textFieldPlaceholder: localizationStringForKey("appirater_review_alert_label_placeholder"), textViewPlaceholder: "Nothing")
        reviewPopupViewController.setLeftButtonTitle(localizationStringForKey("appirater_review_alert_nobutton_title").uppercased()) {
            self.updateRemindLaterDate()
            reviewPopupViewController.dismiss(animated: true, completion: nil)
        }
        
        reviewPopupViewController.setRightButtonTitle(localizationStringForKey("appirater_review_alert_submitbutton_title").uppercased()) { (textFieldText, textViewText) in
            self.submitReview(textFieldText, text: textViewText)
            let controller = UIAlertController(title: self.localizationStringForKey("appirater_thankyou_alert_title"), message: nil, preferredStyle: .alert);
            controller.addAction(UIAlertAction(title: self.localizationStringForKey("appirater_cancel_button_title"), style: .cancel, handler: { (action) in
                reviewPopupViewController.dismiss(animated: true, completion: nil)
            }))
            reviewPopupViewController.present(controller, animated: true, completion: nil)
        }
        return reviewPopupViewController
    }
    
    open func submitReview(_ email : String?, text : String?) {
//        ContentAPIClient.sharedInstance().postFeedbackWithMessage(text, email: email, onSuccess: nil, onError: nil)
    }
    
    func localizationStringForKey(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Appirater", bundle: Bundle.main, comment: "")
    }
    
    func alertIsAppropriate() -> Bool {
        return Reachability.isConnectedToNetwork() && !userDeclinedToRate.value() && !userRatedCurrentVersion.value()
    }
}

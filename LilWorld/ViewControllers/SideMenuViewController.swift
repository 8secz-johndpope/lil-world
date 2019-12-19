//
//  SideMenuViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 05/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import StoreKit

let appleAppId = 1037388546

class SideMenuViewController: UIViewController {
    
    @IBAction func rateUsButtonPressed(_ sender: UIButton) {
        AnalyticsEngine.trackEvent(AnalyticsMenuItemEvent(item: .RateUs))
        openStoreProductWithId(appleAppId)
    }
    
    fileprivate func openStoreProductWithId(_ productId: Int) {
        let appURL = "itms-apps://itunes.apple.com/app/id\(productId)?mt=8"
        UIApplication.shared.openURL(URL(string: appURL)!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let menuItem : AnalyticsMenuItem
        if segue.identifier == "Feed" {
            menuItem = .Feed
        } else if segue.identifier == "Shop" {
            menuItem = .Shop
        } else if segue.identifier == "Create" {
            menuItem = .NewPhoto
        } else {
            menuItem = .AboutUs
        }
        AnalyticsEngine.trackEvent(AnalyticsMenuItemEvent(item: menuItem))
    }

    @IBAction func ourAppsButtonPressed(_ sender: UIButton) {
        let ourAppsURL = URL(string:"http://lil.city")!
        self.showModalWebBrowserWithURL(ourAppsURL)
    }
    
}

extension SideMenuViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

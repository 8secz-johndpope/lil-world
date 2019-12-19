//
//  UIViewController+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 24/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import SafariServices
import SVWebViewController
import StoreKit

//MARK: - Model web browser

extension UIViewController {
    
    func showModalWebBrowserWithURL(_ url: URL) {
        if #available(iOS 9.0, *) {
            self.present(SFSafariViewController(url: url), animated: true, completion: nil)
        } else {
            self.present(SVModalWebViewController(url: url), animated: true, completion: nil)
        }
    }
    
    func showAlertWithPurchaseError(_ error: Error) {
        if !(error is ResponseError) {
            if error._code == 2 {
                return
            }
        }
        let alertController = UIAlertController(title: localized("Alerts_purchaseErrorTitle"), message: localized("Alerts_purchaseErrorMessage"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithRestorePurchasesError(_ error: Error) {
        if error._code == 2 {
            return
        }
        let alertController = UIAlertController(title: localized("Alerts_restorePurchasesErrorTitle"), message: localized("Alerts_restorePurchasesErrorMessage"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Foreground

let foregroundViewTag = 2206

extension UIViewController {
    
    func coverWithForegroundViewWithColor(_ color: UIColor, andSpinner spinner: Bool = false) {
        let foregroundView = UIView()
        foregroundView.backgroundColor = color
        foregroundView.frame = self.view.bounds
        foregroundView.tag = foregroundViewTag
        self.view.addSubview(foregroundView)
        if spinner {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.center = CGPoint(x: foregroundView.bounds.size.width / 2, y: foregroundView.bounds.size.height / 2)
            foregroundView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
        
    }
    
    func removeForegroundView() {
        self.view.viewWithTag(foregroundViewTag)?.removeFromSuperview()
    }
}

//
//  FullVersionViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 25/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import StoreKit

protocol FullVersionBannerDelegate {
    func buyingProcessStarted()
    func buyingProcessFinished()
}

class FullVersionViewController: UIViewController {

    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var buyFullVersionButton: UIButton!
    @IBOutlet weak var buyingActivityIndicator: UIActivityIndicatorView!
    var delegate: FullVersionBannerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listParagraphStyle = NSMutableParagraphStyle()
        listParagraphStyle.lineSpacing = 0
        listParagraphStyle.alignment = .center
        listParagraphStyle.maximumLineHeight = 16
        let listLabelAttributes = [
            NSFontAttributeName: UIFont(name: "Circe-Regular", size: 14)!,
            NSForegroundColorAttributeName: UIColor.white,
            NSParagraphStyleAttributeName:listParagraphStyle
        ]
        let listText = localized("Banner_fullVersionList")
        listLabel.attributedText = NSAttributedString(string: listText, attributes: listLabelAttributes)
        
        buyFullVersionButton.layer.cornerRadius = 3
        
        updateBuyButton()
    }
}

//MARK: - Private

extension FullVersionViewController {
    
    fileprivate func updateBuyButton() {
        if StoreHelper.fullVersionPurchased {
            buyFullVersionButton.setBackgroundImage(UIImage(named: "buy_full_version_button_background_disabled"), for: UIControlState())
            buyFullVersionButton.setTitle("", for: UIControlState())
            buyFullVersionButton.isEnabled = false
            return
        }
        buyFullVersionButton.setBackgroundImage(UIImage(named: "buy_full_version_button_background_enabled"), for: UIControlState())
        var buyButtonTitle = localized("Common_buyButtonTitle")
        if let buyButtonPrice = StoreHelper.fullVersionPriceString() {
            buyButtonTitle = buyButtonPrice + " " + buyButtonTitle
        }
        buyFullVersionButton.setTitle(buyButtonTitle, for: UIControlState())
    }
}

//MARK: - Actions

extension FullVersionViewController {
    
    @IBAction func buyFullVersionButtonPressed(_ sender: UIButton) {
        delegate?.buyingProcessStarted()
        let formSheetPresentingPresentationController = mz_formSheetPresentingPresentationController()
        formSheetPresentingPresentationController?.presentationController?.shouldDismissOnBackgroundViewTap = false
        formSheetPresentingPresentationController?.allowDismissByPanningPresentedView = false
        let contentViewController = formSheetPresentingPresentationController?.contentViewController
        contentViewController?.view.isUserInteractionEnabled = false
        contentViewController?.coverWithForegroundViewWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5))
        buyingActivityIndicator.isHidden = false
        buyingActivityIndicator.startAnimating()
        buyFullVersionButton.setTitle("", for: UIControlState())
        
        SwiftyStoreKit.purchaseProduct(kFullVersionProductId) { (result) -> () in
            switch result {
            case .success(let productId):
                StoreHelper.setFullVersionPurchased(true)
                print(productId)
            case .error(let error):
                self.showAlertWithPurchaseError(error)
            }
            self.delegate?.buyingProcessFinished()
            contentViewController?.removeForegroundView()
            self.buyingActivityIndicator.stopAnimating()
            contentViewController?.view.isUserInteractionEnabled = true
            formSheetPresentingPresentationController?.presentationController?.shouldDismissOnBackgroundViewTap = true
            formSheetPresentingPresentationController?.allowDismissByPanningPresentedView = true
            self.updateBuyButton()
            if let bannerViewController = contentViewController as? BannerViewController {
                bannerViewController.updateBuyButton()
            }
        }
    }
}

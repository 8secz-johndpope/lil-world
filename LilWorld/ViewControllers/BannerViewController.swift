//
//  BannerViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 25/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import StoreKit

class BannerViewController: UIViewController {

    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var setDescriptionLabel: UILabel!
    @IBOutlet weak var setImageView: URLImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var buyingActivityIndicator: UIActivityIndicatorView!
    
    var product: SKProduct? = nil {
        didSet {
            updateBuyButton()
        }
    }
    
    var setObject: Section? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let setObject = setObject else {
            return
        }
        setNameLabel.text = setObject.title.uppercased()
        setDescriptionLabel.text = setObject.description
        if let imageURL = setObject.imageURL {
            setImageView.imageLink = imageURL
        }
        
        updateBuyButton()
    }
    
    func updateBuyButton() {
        guard let buyButton = buyButton else {
            return
        }
        
        if StoreHelper.fullVersionPurchased {
            buyButton.setBackgroundImage(UIImage(named: "buy_set_button_background_disabled"), for: UIControlState())
            buyButton.setTitle("", for: UIControlState())
            buyButton.isEnabled = false
            return
        }
        
        if let product = product {
            if (StoreHelper.fullVersionPurchased || StoreHelper.sharedInstance.getPurchasedProductsIds().contains(product.productIdentifier)) {
                buyButton.setBackgroundImage(UIImage(named: "buy_set_button_background_disabled"), for: UIControlState())
                buyButton.setTitle("", for: UIControlState())
                buyButton.isEnabled = false
                return
            }
            buyButton.setBackgroundImage(UIImage(named: "buy_set_button_background_enabled"), for: UIControlState())
            let formatter = NumberFormatter()
            formatter.formatterBehavior = .behavior10_4
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            let priceString = formatter.string(from: product.price)
            buyButton.setTitle(priceString, for: UIControlState())
        } else {
            buyButton.setTitle("BUY", for: UIControlState())
        }
    }
}

//MARK: - Actions

extension BannerViewController {
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        guard let productId = setObject?.product_id else {
            return
        }
        
        let formSheetPresentingPresentationController = mz_formSheetPresentingPresentationController()
        formSheetPresentingPresentationController?.presentationController?.shouldDismissOnBackgroundViewTap = false
        formSheetPresentingPresentationController?.allowDismissByPanningPresentedView = false
        let contentViewController  = formSheetPresentingPresentationController?.contentViewController
        contentViewController?.view.isUserInteractionEnabled = false
        contentViewController?.coverWithForegroundViewWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5))
        buyingActivityIndicator.isHidden = false
        buyingActivityIndicator.startAnimating()
        buyButton.setTitle("", for: UIControlState())
        
        SwiftyStoreKit.purchaseProduct(productId) { (result) -> () in
            switch result {
            case .success(let productId):
                StoreHelper.sharedInstance.addProductId(productId)
                print(productId)
            case .error(let error):
                self.showAlertWithPurchaseError(error)
            }
            
            contentViewController?.removeForegroundView()
            self.buyingActivityIndicator.stopAnimating()
            contentViewController?.view.isUserInteractionEnabled = true
            formSheetPresentingPresentationController?.presentationController?.shouldDismissOnBackgroundViewTap = true
            formSheetPresentingPresentationController?.allowDismissByPanningPresentedView = true
            self.updateBuyButton()
        }
    }
}

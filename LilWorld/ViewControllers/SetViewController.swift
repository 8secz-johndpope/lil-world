//
//  SetViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 09/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import CoreData

class SetViewController: UIViewController {

    @IBOutlet weak var setTypeLabel: UILabel!
    @IBOutlet weak var setImageView: URLImageView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setDescriptionLabel: UILabel!
    @IBOutlet weak var buySetButton: UIButton!
    @IBOutlet weak var buyingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var setCollectionView: UICollectionView!
    var setObject: Section!
    var mainSet = true
    
    fileprivate var _stickersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var stickersFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _stickersFetchedResultsController == nil {
            let section_id = setObject?.section_id ?? -1
            _stickersFetchedResultsController = Sticker.mr_fetchAllGrouped(by: "sticker_id", with: NSPredicate(format:"section_id = \(section_id)"), sortedBy: "position", ascending: true)
        }
        return _stickersFetchedResultsController!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTypeLabel.text = localized(mainSet ? "SetVC_titleMain" : "SetVC_titleExtra")
        setTitleLabel.text = setObject.title.uppercased()
        setDescriptionLabel.text = setObject.description
        setImageView.imageLink = setObject.imageURL
        updateBuyButton()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureRecognized(_:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
        stickersFetchedResultsController.delegate = self
    }
}

//MARK: - Private

extension SetViewController {
    
    fileprivate func updateBuyButton() {
        guard let buySetButton = buySetButton else {
            return
        }
        
        if setObject.product_id == nil || StoreHelper.fullVersionPurchased || StoreHelper.sharedInstance.getPurchasedProductsIds().contains(setObject.product_id!) {
            buySetButton.setBackgroundImage(UIImage(named: "buy_set_button_background_disabled"), for: UIControlState())
            buySetButton.setTitle("", for: UIControlState())
            buySetButton.isEnabled = false
            return
        } else {
            buySetButton.isEnabled = true
            buySetButton.setTitle(localized("Common_buyButtonTitle"), for: UIControlState())
            SwiftyStoreKit.retrieveProductInfo(setObject.product_id!, completion: { (result) -> () in
                if case .success(let product) = result {
                    self.buySetButton.setBackgroundImage(UIImage(named: "buy_set_button_background_enabled"), for: UIControlState())
                    let formatter = NumberFormatter()
                    formatter.formatterBehavior = .behavior10_4
                    formatter.numberStyle = .currency
                    formatter.locale = product.priceLocale
                    let priceString = formatter.string(from: product.price)
                    self.buySetButton.setTitle(priceString, for: UIControlState())
                }
            })
        }
    }
}

//MARK: - Actions

extension SetViewController {
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        self.coverWithForegroundViewWithColor(UIColor(red: 1, green:1, blue: 1, alpha: 0.5))
        self.view.isUserInteractionEnabled = false
        buyingActivityIndicator.isHidden = false
        buyingActivityIndicator.startAnimating()
        buySetButton.setTitle("", for: UIControlState())
        SwiftyStoreKit.purchaseProduct(setObject.product_id!, completion: { (result) -> () in
            switch result {
            case .success(let productId):
                StoreHelper.sharedInstance.addProductId(productId)
                print(productId)
            case .error(let error):
                self.showAlertWithPurchaseError(error)
            }
            self.removeForegroundView()
            self.view.isUserInteractionEnabled = true
            self.updateBuyButton()
            self.buyingActivityIndicator.stopAnimating()
        })
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func swipeGestureRecognized(_ gesture: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - CollectionViews DataSource

extension SetViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickersFetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == setCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetCollectionViewCell", for: indexPath) as? SetCollectionViewCell {
                if let object = stickersFetchedResultsController.fetchedObjects?[indexPath.row] as? Sticker {
                    if let imageURL = object.image_url {
                        cell.stickerImageView.imageLink = imageURL
                    }
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
}

//MARK: - Cell sizes and insets

extension SetViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == setCollectionView {
            if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
                return CGSize(width: 85, height: 85)
            } else if DeviceType.IS_IPHONE_6 {
                return CGSize(width: 105, height: 105)
            } else {
                return CGSize(width: 118, height: 118)
            }
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}

//MARK: - NSFetchedResultsControllerDelegate

extension SetViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setCollectionView.reloadData()
    }
}

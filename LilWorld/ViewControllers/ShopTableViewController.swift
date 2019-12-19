//
//  ShopTableViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 03/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import CoreData

protocol ShopTableViewControllerDelegate {
    func buyingProcessStarted()
    func buyingProcessFinished()
    func selectedCellWithObject(_ object: Section)
}

class ShopTableViewController: UIViewController {

    @IBOutlet weak var setsTableView: UITableView!
    @IBOutlet weak var fullVersionBannerView: UIView!
    var delegate: ShopTableViewControllerDelegate? = nil
    var mainSets = true
    
    fileprivate struct Constants {
        static let fullVersionBannerHeight: CGFloat = 180
        static let cellHeight: CGFloat = 80
    }
    
    fileprivate var _setsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var setsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _setsFetchedResultsController == nil {
            if let firstLevelObjects = Section.mr_findAll(with: NSPredicate(format: "parent_id = 0 AND extra = \(!mainSets)")) as? [Section] {
                let firstLevelObjectsIDs = firstLevelObjects.map({ (section) -> Int in
                    return Int(section.section_id)
                })
                _setsFetchedResultsController = Section.mr_fetchAllGrouped(by: "parent_id", with: NSPredicate(format: "parent_id IN %@", firstLevelObjectsIDs), sortedBy: "parent_id,position", ascending: true)
            }
        }
        return _setsFetchedResultsController!
    }
}

//MARK: -  Lifecycle

extension ShopTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setsFetchedResultsController.delegate = self
        bannerSetup()
        setsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateBanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateBanner()
    }
}

extension ShopTableViewController {
    
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? SetTableViewCell,
            let productId = cell.productId {
                delegate?.buyingProcessStarted()
                cell.buyingActivityIndicator.isHidden = false
                cell.buyingActivityIndicator.startAnimating()
                cell.buyButton.setTitle("", for: UIControlState())
                SwiftyStoreKit.purchaseProduct(productId, completion: { (result) -> () in
                    switch result {
                    case .success(let productId):
                        StoreHelper.sharedInstance.addProductId(productId)
                        print(productId)
                    case .error(let error):
                        self.showAlertWithPurchaseError(error)
                    }
                    self.delegate?.buyingProcessFinished()
                    cell.buyingActivityIndicator.stopAnimating()
                })
        }
    }
}

//MARK: - Public

extension ShopTableViewController {
    
    func updateInterfaceWithCurrentPurchases() {
        bannerSetup()
        if let setsTableView = setsTableView {
            setsTableView.reloadData()
        }
    }
    
}

//MARK: - Private

extension ShopTableViewController {
    
    fileprivate func bannerSetup() {
        if StoreHelper.fullVersionPurchased {
            fullVersionBannerView?.removeFromSuperview()
            fullVersionBannerView = nil
        } else {
            if let bannerVC = self.childViewControllers.first as? FullVersionViewController {
                bannerVC.delegate = self
            }
        }
    }
    
    fileprivate func updateBanner() {
        guard fullVersionBannerView != nil else {
            return
        }
        fullVersionBannerView.frame = CGRect(x: 0, y: -setsTableView.contentOffset.y, width: self.view.frame.width, height: Constants.fullVersionBannerHeight)
    }
}

//MARK: - UITableViewDataSource

extension ShopTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setsFetchedResultsController.fetchedObjects!.count + (StoreHelper.fullVersionPurchased ? 0 : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let setTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SetTableViewCell", for: indexPath) as? SetTableViewCell {
            if (indexPath.row == 0 && !StoreHelper.fullVersionPurchased) {
                return setTableViewCell
            }
            let row = StoreHelper.fullVersionPurchased ? indexPath.row : indexPath.row - 1
            if let object = setsFetchedResultsController.fetchedObjects?[row] as? Section {
                setTableViewCell.setImageView.imageLink = object.imageURL
                setTableViewCell.setTitleLabel.text = object.title.uppercased()
                setTableViewCell.setDescriptionLabel.text = object.description
                
                if (object.product_id == nil || StoreHelper.fullVersionPurchased || StoreHelper.sharedInstance.getPurchasedProductsIds().contains(object.product_id!)) {
                    setTableViewCell.productId = nil
                    setTableViewCell.buyButton.setBackgroundImage(UIImage(named: "buy_set_button_background_disabled"), for: UIControlState())
                    setTableViewCell.buyButton.setTitle("", for: UIControlState())
                    setTableViewCell.buyButton.isEnabled = false
                } else {
                    setTableViewCell.buyButton.isEnabled = true
                    setTableViewCell.productId = object.product_id
                    setTableViewCell.buyButton.setTitle("BUY", for: UIControlState())
                    SwiftyStoreKit.retrieveProductInfo(object.product_id!, completion: { (result) -> () in
                        if case .success(let product) = result {
                            if let cellProductId = setTableViewCell.productId {
                                if cellProductId == product.productIdentifier {
                                    setTableViewCell.buyButton.setBackgroundImage(UIImage(named: "buy_set_button_background_enabled"), for: UIControlState())
                                    let formatter = NumberFormatter()
                                    formatter.formatterBehavior = .behavior10_4
                                    formatter.numberStyle = .currency
                                    formatter.locale = product.priceLocale
                                    let priceString = formatter.string(from: product.price)
                                    setTableViewCell.buyButton.setTitle(priceString, for: UIControlState())
                                }
                            }
                        }
                    })
                }
            }
            
            return setTableViewCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && !StoreHelper.fullVersionPurchased {
            return Constants.fullVersionBannerHeight
        } else {
            return Constants.cellHeight
        }
    }
}

//MARK: - UITableViewDelegate

extension ShopTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && !StoreHelper.fullVersionPurchased {
            return
        }
        let row = StoreHelper.fullVersionPurchased ? indexPath.row : indexPath.row - 1
        if let object = setsFetchedResultsController.fetchedObjects?[row] as? Section {
            delegate?.selectedCellWithObject(object)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBanner()
    }
}

//MARK: - FullVersionBannerDelegate

extension ShopTableViewController: FullVersionBannerDelegate {
    
    func buyingProcessStarted() {
        delegate?.buyingProcessStarted()
    }
    
    func buyingProcessFinished() {
        delegate?.buyingProcessFinished()
    }
}

//MARK: - NSFetchedResultsControllerDelegate

extension ShopTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.setsTableView.reloadData()
    }
}

//
//  StoreHelper.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 13/09/15.
//  Copyright © 2015 Adno. All rights reserved.
//

import Foundation
import StoreKit

let kFullVersionUserDefaultsKey = "Store.FullVersionPurchased"
let kFullVersionPriceStringUserDefaultsKey = "Store.FullVersionPriceString"
let kPurchasedProductsIdsKey = "Store.PurchasedProductsIds"

let kFullVersionProductId = "com.lilworld.all.illustrations"

class StoreHelper: NSObject {
    static let sharedInstance = StoreHelper()
    fileprivate var purchasedProductsIds: [String]?  = nil
    
    class var fullVersionPurchased: Bool {
        return UserDefaults.standard.bool(forKey: kFullVersionUserDefaultsKey)
    }
    
    class func setFullVersionPurchased(_ purchased: Bool) {
        UserDefaults.standard.set(purchased, forKey: kFullVersionUserDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    class func fullVersionPriceString() -> String? {
        return UserDefaults.standard.string(forKey: kFullVersionPriceStringUserDefaultsKey)
    }
    
    func getPurchasedProductsIds() -> [String] {
        if let purchasedProductsIds = self.purchasedProductsIds {
            return purchasedProductsIds
        }
        if let purchasedProductsIdsData = UserDefaults.standard.object(forKey: kPurchasedProductsIdsKey) as? Data {
            if let purchasedProductsIds = NSKeyedUnarchiver.unarchiveObject(with: purchasedProductsIdsData) as? [String] {
                self.purchasedProductsIds = purchasedProductsIds
                return purchasedProductsIds
            }
        }
        self.purchasedProductsIds = []
        return []
    }
    
    func addProductId(_ productId: String) {
        if productId == kFullVersionProductId {
            StoreHelper.setFullVersionPurchased(true)
        }
        if self.purchasedProductsIds == nil {
            _ = getPurchasedProductsIds()
        }
        if (!(self.purchasedProductsIds!.contains(productId))) {
            self.purchasedProductsIds?.append(productId)
        }
        savePurchasedProductsIds(self.purchasedProductsIds!)
    }
    
    func savePurchasedProductsIds(_ idsArray:[String]) {
        let idsData = NSKeyedArchiver.archivedData(withRootObject: idsArray)
        UserDefaults.standard.set(idsData, forKey: kPurchasedProductsIdsKey)
        UserDefaults.standard.synchronize()
    }
}

//MARK: - Public interface

extension StoreHelper {
    
    func requestProductsInfo(_ productIDs:[String], completion: ( (_ success: Bool) -> ())? ) {
        for productID in productIDs {
            SwiftyStoreKit.retrieveProductInfo(productID, completion: { (result) -> () in
                switch result {
                case .success(let product):
                    print("retrieved info about product with id: \(product.productIdentifier)")
                case .error(let error):
                    print("retrieve info finished with error: \(error)")
                }
            })
        }
    }
    
    func requestFullVersionProductsInfo(_ completion: ( (_ success: Bool) -> ())? ) {
        SwiftyStoreKit.retrieveProductInfo(kFullVersionProductId) { result in
            switch result {
            case .success(let product):
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                let fullVersionPriceString = formatter.string(from: product.price)
                UserDefaults.standard.set(fullVersionPriceString, forKey: kFullVersionPriceStringUserDefaultsKey)
                break
            case .error(_):
                break
            }
        }
    }
    
    func purchaseProduct(productId: String, completion: ( (_ success: Bool) -> ())? ) {
        
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success(let productId):
                print("Purchase Success: \(productId)")
                completion?(true)
                break
            case .error(let error):
                print("Purchase Failed: \(error)")
                completion?(false)
                break
            }
        }
    }
    
    func restorePurchases(_ completion: ( (_ productId: String?, _ nothingToRestore: Bool, _ error:Error?) -> ())? ) {
        SwiftyStoreKit.restorePurchases { (result) -> () in
            switch result {
            case .success(let productId):
                completion?(productId, false, nil)
                break
            case .error(let error):
                completion?(nil, false, error)
                break
            case .nothingToRestore:
                completion?(nil, true, nil)
                break
            }
        }
    }
    
}

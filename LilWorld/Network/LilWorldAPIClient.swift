//
//  LilWorldAPIClient.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 14/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation
import Alamofire
import MagicalRecord

class LilWorldAPIClient {
    
    static let sharedInstance = LilWorldAPIClient()
    
    class func getProductIDs(_ completionHandler: @escaping ([String]) -> Void) {
        Alamofire.request(LilWorldAPIRouter.productIDs).responseJSON { response in
            if response.result.isSuccess,
                let responseValue = response.result.value as? [String: Any],
                let productsIDs = responseValue["product_ids"] as? [String] {
                completionHandler(productsIDs)
            }
        }
    }
    
    class func updateSectionsIfNeeded() {
        Alamofire.request(LilWorldAPIRouter.treeHash).responseJSON { response in
            guard let responseValue = response.result.value as? [String : Any]  else {
                return
            }
            
            guard response.result.isSuccess, let md5Hash = responseValue["md5"] as? String else {
                return
            }
            
            guard md5Hash != SectionsManager.currentTreeHash || LanguageHelper.lastSavedTreeLanguage() != LanguageHelper.currentLanguageISOCode() else {
                //nothing changed
                return
            }


            let sectionsRequest = Alamofire.request(LilWorldAPIRouter.sections(LanguageHelper.currentLanguageISOCode()))
            sectionsRequest.responseJSON(completionHandler: { response in
                guard let sectionsResponseValue = response.result.value as? [String : Any]  else {
                    return
                }
                guard response.result.isSuccess, let sections = sectionsResponseValue["sections"] as? [[String : AnyObject]] else {
                    return
                }
                ModelManager.saveSectionsWithArray(sections, completion: { leaves in
                    Alamofire.request(LilWorldAPIRouter.stickers(leaves)).responseJSON(completionHandler: { response in
                        guard let stickersResponseValue = response.result.value as? [String : Any]  else {
                            return
                        }
                        guard response.result.isSuccess, let files = stickersResponseValue["files"] as? [[String : AnyObject]] else {
                            return
                        }

                        ModelManager.saveStickers(files)
                        SectionsManager.currentTreeHash = md5Hash
                        LanguageHelper.saveCurrentTreeLanguage()
                        #if DEBUG
                        ModelManager.printLeavesTitlesAndFirstThreeImageURLs(leaves)
                        #endif
                    })
                })
            })
        }
    }
    
    class func uploadContestImage(_ params: [String: Any], progressBlock: ((Double) -> Void)? = nil, successBlock: (() -> ())?, errorBlock: (() -> ())?) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if let image = params[key] as? UIImage, let imageData = UIImageJPEGRepresentation(image, 1) {
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                }
                else if let stringParam = value as? String {
                    multipartFormData.append(stringParam.data(using: .utf8)!, withName: key)
                }
            }

        },
                         with: LilWorldAPIRouter.contestUpload, encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.uploadProgress(queue: DispatchQueue.main, closure: { progress in
                                    let relativeProgress = Double(progress.completedUnitCount / progress.totalUnitCount)
                                    progressBlock?(relativeProgress)
                                })
                                upload.responseJSON { response in
                                    guard response.result.isSuccess else {
                                        
                                        errorBlock?()
                                        return
                                    }
                                    guard let responseObject = response.result.value as? [String : AnyObject],
                                        let responseDataNode = responseObject["contest_file"], (responseDataNode as? NSNull) == nil else {
                                            errorBlock?()
                                            return
                                    }
                                    successBlock?()
                                }
                            case .failure( _):
                                errorBlock?()
                            }

        })
    }
}

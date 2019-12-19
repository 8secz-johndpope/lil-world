//
//  DBLoader.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 03/09/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit
import MagicalRecord

class ModelManager {
    
    class func loadDBFromFileIfNeeded() {
        if Section.mr_findFirst() == nil {
            self.loadDBFromFile()
        }
    }
    
    class func loadDBFromFile() {
        if let sectionsJsonData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "DefaultSections", ofType: "json")!)),
            let sections =  (try? JSONSerialization.jsonObject(with: sectionsJsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? Array<Dictionary<String, AnyObject>> {
                saveSectionsWithArray(sections, completion: nil)
        }
        if let stickersJsonData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "DefaultStickers", ofType: "json")!)),
            let stickers =  (try? JSONSerialization.jsonObject(with: stickersJsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? Array<Dictionary<String, AnyObject>> {
                saveStickers(stickers)
        }
    }
    
    class func saveStickers(_ stickers: [[String:AnyObject]]) {
        MagicalRecord.save({ context in
            Sticker.mr_truncateAll(in: context)
            for sticker in stickers {
                if let newSticker = Sticker.mr_createEntity(in: context) {
                    newSticker.position = (sticker["position_at_section"] as? NSNumber)?.int32Value ?? 0
                    newSticker.section_id = (sticker["section_id"] as? NSNumber)?.int32Value ?? 0
                    newSticker.sticker_id = (sticker["id"] as! NSNumber).int32Value
                    newSticker.product_id = sticker["product_id"] as? String
                    newSticker.object_md5 = sticker["object_md5"] as? String
                    newSticker.image_url = sticker["uri"] as? String
                    newSticker.image_name = "transport_3"
                }
            }
        })
    }
    
    class func saveSectionsWithArray(_ sections: [[String:AnyObject]], completion: ((_ leaves:[Int]) -> Void)?) {
        var leavesArray: [Int] = []
        MagicalRecord.save({ context -> Void in
            Section.mr_truncateAll(in: context)
            ModelManager.saveSectionsLevelWithArray(sections, withContext: context, leavesArray: &leavesArray)
            }) { (success, error) -> Void in
            completion?(leavesArray)
        }
    }
    
    fileprivate class func saveSectionsLevelWithArray(_ sections: [[String:AnyObject]], withContext context:NSManagedObjectContext, leavesArray:inout [Int]) {
        for section in sections {
            if let newSection = Section.mr_createEntity(in: context) {
                newSection.position = (section["position"] as? NSNumber)?.int32Value ?? 0
                newSection.extra = section["extra"] as? Bool ?? false
                newSection.parent_id = (section["parent_id"] as? NSNumber)?.int32Value ?? 0
                newSection.section_id = (section["id"] as! NSNumber).int32Value
                newSection.product_id = section["product_id"] as? String
                newSection.object_md5 = section["object_md5"] as? String
                newSection.tree_md5 = section["tree_md5"] as? String
                if let rel = section["rel"] as? [String:AnyObject],
                   var titlesDict = rel["title_alias"] as? [String:AnyObject],
                   var descriptionsDict = rel["description_alias"] as? [String:AnyObject],
                   var imagesDict = rel["image_alias"] as? [String:AnyObject] {
                    for (lang, titleDict) in titlesDict {
                        if let title = (titleDict as? [String:AnyObject])?["title"] as? String {
                            titlesDict[lang] = title as AnyObject?
                        }
                    }
                    for (lang, descriptionDict) in descriptionsDict {
                        if let description = (descriptionDict as? [String:AnyObject])?["description"] as? String {
                            descriptionsDict[lang] = description as AnyObject?
                        }
                    }
                    for (lang, imageDict) in imagesDict {
                        if let imageURL = (imageDict as? [String:AnyObject])?["uri"] as? String {
                            imagesDict[lang] = imageURL as AnyObject?
                        }
                    }
                    newSection.titles = titlesDict as? [String:String]
                    newSection.descriptions = descriptionsDict as? [String:String]
                    newSection.image_urls = imagesDict as? [String:String]
                }
                if let children = section["children"] as? [[String:AnyObject]], children.count > 0 {
                    saveSectionsLevelWithArray(children, withContext: context, leavesArray: &leavesArray)
                } else {
                    leavesArray.append(Int(newSection.section_id))
                }
            }
        }
    }
    
    class func printLeavesTitlesAndFirstThreeImageURLs(_ leaves:[Int]) {
        for leaf in leaves {
            if let stickers = Sticker.mr_findAllSorted(by: "position", ascending: true, with: NSPredicate(format: "section_id = \(leaf)")) as? [Sticker] {
                if stickers.count > 3 {
                    let section = Section.mr_findFirst(byAttribute: "section_id", withValue: leaf)
                    print(section!.title)
                    for i in 0..<3 {
                        print(stickers[i].image_url!)
                    }
                }
            }
        }
    }
}

//
//  Section.swift
//  
//
//  Created by Roman Fedyanin on 14/03/16.
//
//

import Foundation
import CoreData


class Section: NSManagedObject {

    var title: String {
        guard let titles = titles else {
            print("nil titles!")
            return ""
        }
        if let title = titles[LanguageHelper.currentLanguageISOCode()] {
            return title
        }
        return titles["en"]!
    }
    
    var imageURL: String? {
        guard let image_urls = image_urls else {
            return nil
        }
        if let imageURL = image_urls[LanguageHelper.currentLanguageISOCode()] {
            return imageURL
        }
        if let enImageURL = image_urls["en"] {
            return enImageURL
        }
        return nil
    }
    
    var image_name: String? {
        return "transport_3"
    }
    
    override var description: String {
        guard let descriptions = descriptions else {
            print("nil descriptions!")
            return ""
        }
        if let description = descriptions[LanguageHelper.currentLanguageISOCode()] {
            return description
        }
        return descriptions["en"] ?? "No description"
    }
}

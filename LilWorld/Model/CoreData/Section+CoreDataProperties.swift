//
//  Section+CoreDataProperties.swift
//  
//
//  Created by Roman Fedyanin on 14/03/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Section {

    @NSManaged var descriptions: [String:String]?
    @NSManaged var extra: Bool
    @NSManaged var image_urls: [String:String]?
    @NSManaged var object_md5: String?
    @NSManaged var parent_id: Int32
    @NSManaged var position: Int32
    @NSManaged var product_id: String?
    @NSManaged var section_id: Int32
    @NSManaged var titles: [String:String]?
    @NSManaged var tree_md5: String?

}

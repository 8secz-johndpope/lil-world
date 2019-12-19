//
//  Sticker+CoreDataProperties.swift
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

extension Sticker {

    @NSManaged var image_name: String?
    @NSManaged var image_url: String?
    @NSManaged var object_md5: String?
    @NSManaged var position: Int32
    @NSManaged var product_id: String?
    @NSManaged var section_id: Int32
    @NSManaged var sticker_id: Int32

}

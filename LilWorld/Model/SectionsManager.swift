//
//  SectionsManager.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 14/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation

class SectionsManager {
    
    static var currentTreeHash:String? {
        get {
            return UserDefaults.standard.value(forKey: "tree_hash") as? String
        }
        set(newTreeHash) {
            UserDefaults.standard.set(newTreeHash, forKey: "tree_hash")
        }
    }
}

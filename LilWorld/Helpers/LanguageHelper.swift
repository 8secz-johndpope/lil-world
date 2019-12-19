//
//  LanguageHelper.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 16/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class LanguageHelper {
    
    class func currentLanguageISOCode() -> String {
        return (Locale.preferredLanguages[0] as NSString).substring(to: 2)
    }
    
    class func lastSavedTreeLanguage() -> String? {
        return UserDefaults.standard.string(forKey: "last_saved_tree_language")
    }
    
    class func saveCurrentTreeLanguage() {
        UserDefaults.standard.set(currentLanguageISOCode(), forKey: "last_saved_tree_language")
    }

}

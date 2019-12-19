//
//  UIFont+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 06/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func logAllFonts() {
        for family in UIFont.familyNames as [String] {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}

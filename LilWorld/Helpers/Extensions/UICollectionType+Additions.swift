//
//  UICollectionType+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 05/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}

//
//  CommonHelpers.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 20/05/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

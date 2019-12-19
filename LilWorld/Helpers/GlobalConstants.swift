//
//  GlobalConstants.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 07/09/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit

struct GlobalConstants {
    
    static let kMainFontKern = NSNumber(value: 1.0 as Double)
    
    static let kTitleAttributes = [
        NSFontAttributeName : UIFont(name: "Circe-Regular", size: 11)!,
        NSKernAttributeName: GlobalConstants.kMainFontKern
    ]
}

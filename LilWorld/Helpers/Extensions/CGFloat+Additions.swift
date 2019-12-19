//
//  CGFloat+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 14/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(RAND_MAX))
    }
}

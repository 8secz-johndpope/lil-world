//
//  UIView+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 10/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

extension UIView {
    
    func bringToFront() {
        self.superview?.bringSubview(toFront: self)
    }
    
    func sendToBack() {
        self.superview?.sendSubview(toBack: self)
    }
}

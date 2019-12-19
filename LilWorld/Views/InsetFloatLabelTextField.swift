//
//  InsetFloatLabelTextField.swift
//  ArtMosSphere
//
//  Created by Aleksandr Novikov on 25.07.16.
//  Copyright © 2016 Kula Tech. All rights reserved.
//

import UIKit

class InsetFloatLabelTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        return UIEdgeInsetsInsetRect(superRect, UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

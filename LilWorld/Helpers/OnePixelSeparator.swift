//
//  OnePixelSeparator.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 12/09/15.
//  Copyright © 2015 Adno. All rights reserved.
//

import UIKit

class OnePixelSeparator: UIView {

    override func awakeFromNib() {
        let sortaPixel = 1.0/UIScreen.main.scale
        let topSeparatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: sortaPixel))
        topSeparatorView.autoresizingMask = [UIViewAutoresizing.flexibleWidth]
        topSeparatorView.isUserInteractionEnabled = false
        topSeparatorView.backgroundColor = self.backgroundColor
        self.addSubview(topSeparatorView)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
    }
}

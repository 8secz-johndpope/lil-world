//
//  CGRect+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 15/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

extension CGRect {
    
    func getRectInsideWithRatio(_ ratio: CGFloat) -> CGRect {
        let selfRatio = self.width / self.height
        if selfRatio > ratio {
            let targetWidth = self.height * ratio
            return CGRect(x: 0.5 * (self.width - targetWidth), y: 0, width: targetWidth, height: self.height)
        } else {
            let targetHeight = self.width / ratio
            return CGRect(x: 0, y: 0.5 * (self.height - targetHeight), width: self.width, height: targetHeight)
        }
    }
}

func CGRectMake(center: CGPoint, size: CGSize) -> CGRect {
    return CGRect(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5, width: size.width, height: size.height)
}

func CGRectMake(center: CGPoint, size: CGFloat) -> CGRect {
    return CGRect(x: center.x - size * 0.5, y: center.y - size * 0.5, width: size, height: size)
}

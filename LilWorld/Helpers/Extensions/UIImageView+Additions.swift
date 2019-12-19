//
//  UIImageView+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 14/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func getRotationTransformСircumscribedWithAngle(_ angle: Float) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        guard let imageSize = image?.size else {
            return transform
        }
        let widthGreaterHeight = imageSize.width > imageSize.height
        let alpha = widthGreaterHeight ? atan(imageSize.width/imageSize.height) : atan(imageSize.height/imageSize.width)
        let y = (widthGreaterHeight ? imageSize.height : imageSize.width) * 0.5 / cos(alpha - CGFloat(abs(angle)))
        let coeff = sqrt(pow(imageSize.width,2) + pow(imageSize.height,2)) * 0.5 / y
        let scale = CGFloat(coeff)
        transform = CGAffineTransform(scaleX: scale, y: scale)
        return transform.rotated(by: CGFloat(angle))
    }
    
    func fitInSuperview() {
        guard let superview = superview,
            let image = image else {
                return
        }
        let imageAspectRatio = image.size.width / image.size.height
        let superviewAspectRatio = superview.frame.size.width / superview.frame.size.height
        if (imageAspectRatio < superviewAspectRatio) {
            let imageWidth = superview.frame.size.height * imageAspectRatio
            frame = CGRect(x: 0.5 * (superview.frame.size.width - imageWidth), y: 0, width: imageWidth, height: superview.frame.size.height)
        } else {
            let imageHeight = superview.frame.size.width / imageAspectRatio
            frame = CGRect(x: 0, y: 0.5 * (superview.frame.size.height - imageHeight), width: superview.frame.size.width, height: imageHeight)
        }
    }
}

//
//  Corners.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 13/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
}

extension UIImageView {
    
    func cornerCenter(_ corner:Corner, initialRadius: CGFloat) -> CGPoint {
        let transformRotationInRadians = -atan2f(Float(self.transform.b), Float(self.transform.a))
        let multiplier: Float = (corner == .topRight || corner == .bottomLeft) ? 1.0 : -1.0
        let additionalAngle = (corner == .topLeft || corner == .bottomLeft) ? Float(Double.pi) : 0
        let initialRotationInRadians = multiplier * Float(atan2f(Float(self.image!.size.height), Float(self.image!.size.width))) + additionalAngle
        let rotationInRadians = transformRotationInRadians + initialRotationInRadians
        let scale = sqrt(self.transform.a * self.transform.a + self.transform.c * self.transform.c)
        let radius = abs(scale * CGFloat(initialRadius))
        let x = self.center.x + radius * CGFloat(cos(rotationInRadians))
        let y = self.center.y - radius * CGFloat(sin(rotationInRadians))
        return CGPoint(x: x, y: y)
    }
}

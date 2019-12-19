//
//  GradientView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 25/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class GradientView: UIView {

    enum GradientDirection {
        case vertical, horizontal
    }
    
    @IBInspectable var startColor: UIColor
    @IBInspectable var endColor: UIColor
    @IBInspectable var gradientDirection: GradientDirection = .horizontal
    
    override init(frame: CGRect) {
        self.startColor = UIColor.white
        self.endColor  = UIColor.black
        gradientDirection = .vertical
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.startColor = UIColor.white
        self.endColor  = UIColor.black
        gradientDirection = .horizontal
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, startColor:UIColor, endColor: UIColor, gradientDirection: GradientDirection = .vertical) {
        self.startColor = startColor
        self.endColor  = endColor
        self.gradientDirection = gradientDirection
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let startColor = self.startColor.cgColor
        let endColor = self.endColor.cgColor
        
        switch gradientDirection {
        case .horizontal:
            drawHorizontalLinearGradientWithContext(context, inRect: rect, startColor: startColor, endColor: endColor)
        case .vertical:
            drawVerticalLinearGradientWithContext(context, inRect: rect, startColor: startColor, endColor: endColor)
        }
    }
}

func drawHorizontalLinearGradientWithContext(_ context: CGContext, inRect rect:CGRect, startColor:CGColor, endColor:CGColor) {
    drawLinearGradientWithContext(context, inRect: rect, startColor: startColor, endColor: endColor, startPoint: CGPoint(x: rect.minX, y: rect.midY), endPoint: CGPoint(x: rect.maxX, y: rect.midY))
}

func drawVerticalLinearGradientWithContext(_ context: CGContext, inRect rect:CGRect, startColor:CGColor, endColor:CGColor) {
    drawLinearGradientWithContext(context, inRect: rect, startColor: startColor, endColor: endColor, startPoint: CGPoint(x: rect.midX, y: rect.minY), endPoint: CGPoint(x: rect.midX, y: rect.maxY))
}

func drawLinearGradientWithContext(_ context: CGContext, inRect rect:CGRect, startColor:CGColor, endColor:CGColor, startPoint:CGPoint, endPoint:CGPoint) {
        
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [startColor, endColor]
    let locations = [0.0, 1.0] as [CGFloat]
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
    context.saveGState()
    context.addRect(rect)
    context.clip()
    
    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [.drawsAfterEndLocation])
    context.restoreGState()
}

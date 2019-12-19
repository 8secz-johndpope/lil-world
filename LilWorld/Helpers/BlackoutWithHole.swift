//
//  BlackoutWithHole.swift
//  GridViewExample
//
//  Created by Roman Fedyanin on 11/02/16.
//  Copyright © 2016 Roman Fedyanin. All rights reserved.
//

import UIKit

class BlackoutWithHole: UIView {
    
    @IBInspectable var blackoutColor: UIColor = UIColor.black.withAlphaComponent(0.7)
    @IBInspectable var holeFrame: CGRect = CGRect.zero {
        didSet {
            if !(oldValue.equalTo(holeFrame)) {
                updateCornersFrames()
                self.setNeedsDisplay()
            }
        }
    }
    @IBInspectable var rowsCount: Int  = 1
    @IBInspectable var columnsCount: Int = 1
    @IBInspectable var corners: Bool = false
    
    var keepRatio: Bool = false
    
    var leftTopCorner: UIImageView!
    var rightTopCorner: UIImageView!
    var leftBottomCorner: UIImageView!
    var rightBottomCorner: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (corners) {
            addCorners()
        }
    }
    
    fileprivate func addCorners() {
        
        leftTopCorner = UIImageView(image: UIImage(named: "pointer_small"))
        rightTopCorner = UIImageView(image: UIImage(named: "pointer_small"))
        leftBottomCorner = UIImageView(image: UIImage(named: "pointer_small"))
        rightBottomCorner = UIImageView(image: UIImage(named: "pointer_small"))
        
        leftTopCorner.isUserInteractionEnabled = true
        rightTopCorner.isUserInteractionEnabled = true
        leftBottomCorner.isUserInteractionEnabled = true
        rightBottomCorner.isUserInteractionEnabled = true
        
        updateCornersFrames()
        
        self.addSubview(leftTopCorner)
        self.addSubview(rightTopCorner)
        self.addSubview(leftBottomCorner)
        self.addSubview(rightBottomCorner)
        
        let leftTopPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        leftTopCorner.addGestureRecognizer(leftTopPanRecognizer)
        let rightTopPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        rightTopCorner.addGestureRecognizer(rightTopPanRecognizer)
        let leftBottomPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        leftBottomCorner.addGestureRecognizer(leftBottomPanRecognizer)
        let rightBottomPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        rightBottomCorner.addGestureRecognizer(rightBottomPanRecognizer)
        
        let commonGesturerecognizer = UIPanGestureRecognizer(target: self, action: #selector(commonPanGestureRecognized(_:)))
        self.addGestureRecognizer(commonGesturerecognizer)
    }
    
    fileprivate func updateCornersFrames() {
        if leftTopCorner == nil {
            return
        }
        leftTopCorner.center = holeFrame.origin
        rightTopCorner.center = CGPoint(x: holeFrame.origin.x + holeFrame.size.width, y: holeFrame.origin.y)
        leftBottomCorner.center = CGPoint(x: holeFrame.origin.x, y: holeFrame.origin.y + holeFrame.size.height)
        rightBottomCorner.center = CGPoint(x: holeFrame.origin.x + holeFrame.size.width, y: holeFrame.origin.y + holeFrame.size.height)
    }
    
    func commonPanGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self)
        if self.bounds.contains(location) {
            let translation = recognizer.translation(in: self)
            if let _ = recognizer.view {
                if holeFrame.origin.x + translation.x >= 0 && holeFrame.origin.x + translation.x + holeFrame.size.width <= self.frame.size.width {
                    holeFrame = CGRect(x: holeFrame.origin.x + translation.x, y: holeFrame.origin.y, width: holeFrame.size.width, height: holeFrame.size.height)
                }
                if holeFrame.origin.y + translation.y >= 0 && holeFrame.origin.y + translation.y + holeFrame.size.height <= self.frame.size.height {
                    holeFrame = CGRect(x: holeFrame.origin.x, y: holeFrame.origin.y + translation.y, width: holeFrame.size.width, height: holeFrame.size.height)
                }
            }
        } else {
            // reset gesture recognizer
            recognizer.isEnabled = false
            recognizer.isEnabled = true
        }
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    func panGestureRecognized(_ recognizer: UIPanGestureRecognizer) {
        var translation = recognizer.translation(in: self)
        if keepRatio {
            let ratio = holeFrame.width / holeFrame.height
            translation.y = translation.x / ratio
        }
        if let view = recognizer.view {
            if (view == leftBottomCorner || view == rightTopCorner) && keepRatio{
                translation.y *= -1
            }
            let newCenterPoint = CGPoint(x:view.center.x + translation.x,
                y:view.center.y + translation.y)
            
            if newCenterPoint.x >= 0 && newCenterPoint.x <= self.frame.size.width &&
                newCenterPoint.y >= 0 && newCenterPoint.y <= self.frame.size.height  {
                
                    var newFrame = CGRect.zero
                    switch view {
                    case leftTopCorner:
                        let bottomRight = CGPoint(x: holeFrame.origin.x + holeFrame.size.width, y: holeFrame.origin.y + holeFrame.size.height)
                        newFrame = CGRect(x: newCenterPoint.x, y: newCenterPoint.y, width: bottomRight.x - newCenterPoint.x, height: bottomRight.y - newCenterPoint.y)
                    case rightTopCorner:
                        let leftBottom = CGPoint(x: holeFrame.origin.x, y: holeFrame.origin.y + holeFrame.size.height)
                        newFrame = CGRect(x: leftBottom.x, y: newCenterPoint.y, width: newCenterPoint.x - leftBottom.x, height: leftBottom.y - newCenterPoint.y)
                    case leftBottomCorner:
                        let rightTopCorner = CGPoint(x: holeFrame.origin.x + holeFrame.width, y: holeFrame.origin.y)
                        newFrame = CGRect(x: newCenterPoint.x, y: rightTopCorner.y, width: rightTopCorner.x - newCenterPoint.x, height: newCenterPoint.y - rightTopCorner.y)
                    case rightBottomCorner:
                        let leftTop = CGPoint(x: holeFrame.origin.x, y: holeFrame.origin.y)
                        newFrame = CGRect(x: leftTop.x, y: leftTop.y, width: newCenterPoint.x - leftTop.x, height: newCenterPoint.y - leftTop.y)
                    default:
                        break
                    }
                    if newFrame.width >= 30 && newFrame.height >= 30 {
                        view.center = newCenterPoint
                        holeFrame = newFrame
                    }
            }
        }
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    override func draw(_ rect: CGRect) {
        
        // Fill full rect with background color except clear hole
        blackoutColor.setFill()
        UIRectFill(rect);
        let holeRectIntersection = holeFrame.intersection(rect);
        UIColor.clear.setFill()
        UIRectFill(holeRectIntersection);
        
        // Draw grid
        let context = UIGraphicsGetCurrentContext()!
        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.white.cgColor)
        
        let columnWidth: Float  = Float(holeFrame.size.width) / Float(self.columnsCount)
        let rowHeight: Float  = Float(holeFrame.size.height) / Float(self.rowsCount)
        for i in 0...self.columnsCount {
            let startPoint = CGPoint(x: holeFrame.origin.x + CGFloat(columnWidth * Float(i)), y: holeFrame.origin.y)
            let endPoint = CGPoint(x: startPoint.x, y: holeFrame.origin.y + holeFrame.size.height)
            context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            context.strokePath();
        }
        for i in 0...self.rowsCount {
            let startPoint = CGPoint(x: holeFrame.origin.x,  y: holeFrame.origin.y + CGFloat(rowHeight * Float(i)))
            let endPoint = CGPoint(x: holeFrame.origin.x + holeFrame.size.width, y: startPoint.y)
            context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            context.strokePath();
        }
    }
    
}

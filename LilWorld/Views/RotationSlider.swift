//
//  RotationSlider.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 14/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

protocol RotationSliderDelegate {
    func rotationSliderValueChanged(_ slider: UISlider)
}

class RotationSlider: UISlider {
    
    fileprivate var backgroundImageView: UIImageView? = nil
    var delegate: RotationSliderDelegate? = nil
    @IBInspectable var linesColor: UIColor? = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)
    
    override var value: Float {
        didSet {
            rotationSliderValueChanged()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if backgroundImageView != nil {
            if backgroundImageView?.image?.size.width != 2 * frame.size.width - 4 {
                let thumbImage = getThumbImage()
                backgroundImageView?.image = thumbImage
                backgroundImageView?.frame = CGRectMake(center: CGPoint.zero, size: thumbImage.size)
                updateBackgroundImagePosition()
            }
        }
    }
    
    override func setValue(_ value: Float, animated: Bool) {
        super.setValue(value, animated: animated)
        if value == 0 {
            rotationSliderValueChanged()
        }
    }
    
    func setup() {
        setThumbImage(UIImage(named: "rotation_slider_thumb"), for: UIControlState())
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
        addTarget(self, action: #selector(rotationSliderValueChanged), for: .valueChanged)
        backgroundImageView = UIImageView(image: getThumbImage())
        addSubview(backgroundImageView!)
    }
}

//MARK: - Private

extension RotationSlider {
    
    @objc fileprivate func rotationSliderValueChanged() {
        updateBackgroundImagePosition()
        delegate?.rotationSliderValueChanged(self)
    }
    
    fileprivate func updateBackgroundImagePosition() {
        backgroundImageView?.center = CGPoint(x: frame.width * 0.5 + CGFloat(value) * frame.width / CGFloat(maximumValue - minimumValue), y: frame.height * 0.5)
    }
    
    fileprivate func getThumbImage() -> UIImage {
        let imageSize = CGSize(width: frame.width * 2 - 4, height: frame.height)
        UIGraphicsBeginImageContext(imageSize)
        let columnsCount = 12
        let columnWidth = imageSize.width / CGFloat(columnsCount)
        if let context = UIGraphicsGetCurrentContext() {
            let lineWidth = 1 / UIScreen.main.scale
            context.setLineWidth(lineWidth)
            context.setStrokeColor((linesColor ?? UIColor.gray).cgColor)
            let lineHeight: CGFloat = 7
            for i in 0...columnsCount {
                let shiftForLine = i == 0 ? lineWidth * 0.5 : -lineWidth * 0.5
                context.move(to: CGPoint(x: CGFloat(i) * columnWidth + shiftForLine, y: imageSize.height * 0.5 - lineHeight))
                context.addLine(to: CGPoint(x: CGFloat(i) * columnWidth + shiftForLine, y: imageSize.height * 0.5))
                context.strokePath()
            }
            context.move(to: CGPoint(x: 0, y: imageSize.height * 0.5 + lineWidth * 0.5))
            context.addLine(to: CGPoint(x: imageSize.width, y: imageSize.height * 0.5 + lineWidth * 0.5))
            context.strokePath()
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @objc fileprivate func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let valueDiff = translation.x * CGFloat(maximumValue - minimumValue) / frame.width
        let newValue = value + Float(valueDiff)
        if newValue < minimumValue {
            value = minimumValue
        } else if newValue > maximumValue {
            value = maximumValue
        } else {
            value = newValue
        }
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
}

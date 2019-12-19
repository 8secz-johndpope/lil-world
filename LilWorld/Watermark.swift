//
//  Watermark.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 24/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class Watermark: UIButton {
    
    fileprivate var currentState: WatermarkState = .normal
    fileprivate var watermarkTimer: Timer? = nil
    
    fileprivate enum WatermarkState {
        case normal, tapToRemove
        
        func imageName() -> String {
            switch self {
            case .normal:
                return "watermark_normal"
            case .tapToRemove:
                return "watermark_remove"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    convenience init(type buttonType: UIButtonType) {
        self.init(frame: CGRect.zero)
        
        let watermarkImage = UIImage(named: currentState.imageName())!
        self.setBackgroundImage(watermarkImage, for: UIControlState())
        self.setBackgroundImage(watermarkImage, for: .highlighted)
        
        
        watermarkTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeWatermark), userInfo: nil, repeats: true)
    }
    
    fileprivate func changeStateToNext() {
        if currentState == .normal {
            currentState = .tapToRemove
        } else {
            currentState = .normal
        }
    }
    
    func changeWatermark() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
            }, completion: { completed -> Void in
                self.changeStateToNext()
                let watermarkImage = UIImage(named: self.currentState.imageName())!
                self.setBackgroundImage(watermarkImage, for: UIControlState())
                self.setBackgroundImage(watermarkImage, for: .highlighted)
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 1.0
                }) 
        }) 
    }
    
}

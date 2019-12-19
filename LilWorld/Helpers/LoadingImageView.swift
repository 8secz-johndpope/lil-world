//
//  LoadingImageView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 08/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class LoadingImageView: UIImageView {

    fileprivate(set) var animatingLoading: Bool = false

    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

//MARK: - Private

extension LoadingImageView {
    
    fileprivate func addAnimation() {
        let spinAnimation = CABasicAnimation(keyPath: "transform.rotation")
        spinAnimation.byValue = 2 * Double.pi
        spinAnimation.duration = animationDuration
        spinAnimation.delegate = self
        layer.add(spinAnimation, forKey: "spin_animation")
    }
    
    fileprivate func setup() {
        self.image = UIImage(named: "image_loader")
        self.animationDuration = 1
    }
}

//MARK: - Public

extension LoadingImageView {
    
    override func startAnimating() {
        guard !animatingLoading  else {
            return
        }
        animatingLoading = true
        addAnimation()
    }
    
    override func stopAnimating() {
        animatingLoading = false
    }
}

//MARK: - Animation delegate

extension LoadingImageView : CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if animatingLoading {
            addAnimation()
        }
    }
}

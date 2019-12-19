//
//  ImageUploadView.swift
//  ArtMosSphere
//
//  Created by Aleksandr Novikov on 27.07.16.
//  Copyright © 2016 Kula Tech. All rights reserved.
//

import UIKit
import DACircularProgress

class ImageUploadView: UIView {

    fileprivate var progressView : DACircularProgressView!
    fileprivate var removeButton : UIButton!
    fileprivate var reloadButton : UIButton!
    fileprivate var overlayView : UIView!
    
    var incrementalProgress: Bool = false
    weak var delegate : ImageUploadViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        
        backgroundColor = UIColor.clear
        
        overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.alpha = 0.2
        overlayView.backgroundColor = UIColor.lightGray
        addSubview(overlayView)
        addConstraint(NSLayoutConstraint(item: overlayView, attribute: .leading, relatedBy: .equal, toItem: overlayView, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: overlayView, attribute: .trailing, relatedBy: .equal, toItem: overlayView, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: overlayView, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: overlayView, attribute: .bottom, relatedBy: .equal, toItem: overlayView, attribute: .bottom, multiplier: 1, constant: 0))
        
        progressView = DACircularProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        progressView.addConstraint(NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40))
        progressView.addConstraint(NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40))
        
        
        removeButton = UIButton(type: .custom)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.setImage(UIImage(named: "delete_action"), for: UIControlState())
        removeButton.addTarget(self, action: #selector(ImageUploadView.removeButtonPressed), for: .touchUpInside)
        addSubview(removeButton)
        addConstraint(NSLayoutConstraint(item: removeButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: removeButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        
        reloadButton = UIButton(type: .custom)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.setImage(UIImage(named: "reload_image_icon"), for: UIControlState())
        reloadButton.addTarget(self, action: #selector(ImageUploadView.reloadButtonPressed), for: .touchUpInside)
        addSubview(reloadButton)
        addConstraint(NSLayoutConstraint(item: reloadButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: reloadButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        reloadButton.isHidden = true
    }
    
    // MARK: - Selectors
    
    func removeButtonPressed() {
        delegate?.uploadViewRemoveButtonPressed(self)
    }
    
    func reloadButtonPressed() {
        delegate?.uploadViewReloadButtonPressed(self)
    }
    
    // MARK: - Public
    
    func beforeLoading() {
        removeButton.isHidden = false
        reloadButton.isHidden = true
        progressView.isHidden = true
        overlayView.isHidden = true
    }
    
    func startLoading() {
        removeButton.isHidden = false
        reloadButton.isHidden = true
        progressView.isHidden = true
        overlayView.isHidden = false
    }
    
    func loadingError() {
        progressView.progress = 0
        removeButton.isHidden = false
        reloadButton.isHidden = false
        progressView.isHidden = true
        overlayView.isHidden = false
    }
    
    func loadingSuccess() {
        progressView.progress = 0
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, animations: {
            weakSelf?.reloadButton.alpha = 0
            weakSelf?.overlayView.alpha = 0
            weakSelf?.progressView.alpha = 0
            }, completion: { (finished) in
                weakSelf?.reloadButton.isHidden = true
                weakSelf?.overlayView.isHidden = true
                weakSelf?.progressView.isHidden = true
                weakSelf?.reloadButton.alpha = 1
                weakSelf?.overlayView.alpha = 0.2
                weakSelf?.progressView.alpha = 1
        }) 
    }
    
    func setProgress(_ progress : Double) {
        var progress = progress
        if incrementalProgress {
            let currentProgress = Double(progressView.progress)
            progress = currentProgress + progress / 2.0
        }
        progressView.progress = CGFloat(progress)
    }
}

protocol ImageUploadViewDelegate : class {
    
    func uploadViewRemoveButtonPressed(_ sender : ImageUploadView)
    func uploadViewReloadButtonPressed(_ sender : ImageUploadView)
}

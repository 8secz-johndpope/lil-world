//
//  URLImageView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 10/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import SDWebImage

class URLImageView: UIImageView {
    
    fileprivate var imageOperation: SDWebImageDownloadToken?
    fileprivate var reloadButton: UIButton?
    var imageLink: String? {
        didSet {
            if oldValue == self.imageLink {
                return
            }
            if let string = self.imageLink, !string.isEmpty {
                reloadImage()
            }
        }
    }
    fileprivate var loadingImageView: LoadingImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addReloadButton()
        startSpinner()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addReloadButton()
        startSpinner()
    }
    
    func prepareForReuse() {
        self.image = nil
        self.imageLink = nil
        reloadButton?.isHidden = true
        SDWebImageManager.shared().imageDownloader?.cancel(imageOperation)
    }
    
    override var image: UIImage? {
        didSet {
            if image != nil {
                stopSpinner()
            }
        }
    }
}

//MARK: - Actions

extension URLImageView {
    
    func reloadButtonPressed(_ sender: UIButton) {
        reloadButton?.isHidden = true
        reloadImage()
    }
}

//MARK: - Private

extension URLImageView {
    
    fileprivate func reloadImage() {
        guard let imageLink = imageLink else {
            return
        }
        image = nil
        let newLink = imageLink.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_")
        if let imageFromBundle = UIImage(named: newLink) {
            handleSuccessLoadingImage(imageFromBundle)
            return
        }
        startSpinner()

        imageOperation = SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: imageLink), options: [], progress: { (receivedSize, expectedSize, url) -> Void in
            
            }, completed: { (image, data, error, finished) -> Void in
                guard error == nil else {
                    self.handleErrorLoadingImage()
                    return
                }
                if finished, let image = image {
                    self.handleSuccessLoadingImage(image)
                }
        })
    }
    
    fileprivate func addReloadButton() {
        self.isUserInteractionEnabled = true
        let reloadButtonSize: CGFloat = 40
        reloadButton = UIButton(type: .custom)
        reloadButton?.setImage(UIImage(named: "sticker_image_reload"), for: UIControlState())
        reloadButton?.addTarget(self, action: #selector(reloadButtonPressed(_:)), for: .touchUpInside)
        reloadButton?.isUserInteractionEnabled = true
        reloadButton?.isHidden = true
        self.addSubview(reloadButton!)
        reloadButton?.frame = CGRect(x: (frame.width - reloadButtonSize) / 2, y: (frame.height - reloadButtonSize) / 2, width: reloadButtonSize, height: reloadButtonSize)
        
        reloadButton?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    fileprivate func startSpinner() {
        guard loadingImageView == nil else {
            return
        }
        loadingImageView = LoadingImageView()
        self.addSubview(loadingImageView!)
        let center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        let size = loadingImageView!.image!.size
        loadingImageView?.frame = CGRect(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5, width: size.width, height: size.height)
        loadingImageView?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        loadingImageView?.startAnimating()
    }
    
    fileprivate func stopSpinner() {
        guard let loadingImageView = loadingImageView else {
            return
        }
        loadingImageView.stopAnimating()
        loadingImageView.removeFromSuperview()
        self.loadingImageView = nil
    }
    
    fileprivate func updateWithLoadedImage(_ image: UIImage) {
        stopSpinner()
        self.image = image
    }
    
    fileprivate func handleSuccessLoadingImage(_ image: UIImage) {
        updateWithLoadedImage(image)
        reloadButton?.isHidden = true
    }
    
    fileprivate func handleErrorLoadingImage() {
        stopSpinner()
        reloadButton?.isHidden = false
    }
    
}

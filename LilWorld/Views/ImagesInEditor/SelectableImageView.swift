//
//  SelectableImageView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 13/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class SelectableImageView: UIImageView {

    fileprivate var sizeImage: UIImageView? = nil
    fileprivate var closeButton: UIButton? = nil
    fileprivate var copyButton: UIButton? = nil

    fileprivate struct Constants {
        static let objectActionButtonsSize = 40.0
        static let initialImageWidth = CGFloat(150)
    }
}

//MARK: - Public

extension SelectableImageView {
    
    func selectWithSender(_ sender: AnyObject) {
        isUserInteractionEnabled = true
        
        closeButton = UIButton(type: .custom)
        closeButton?.setImage(UIImage(named: "delete_button"), for: UIControlState())
        superview?.addSubview(closeButton!)
        closeButton?.frame = getCoordinatesOfCloseButton()
        closeButton?.addTarget(sender, action: #selector(EditorViewController.deleteButtonPressed(_:)), for: .touchUpInside)
        
        copyButton = UIButton(type: .custom)
        copyButton?.setImage(UIImage(named: "copy_button"), for: UIControlState())
        superview?.addSubview(copyButton!)
        copyButton?.frame = getCoordinatesOfCopyButton()
        copyButton?.addTarget(sender, action: #selector(EditorViewController.copyButtonPressed(_:)), for: .touchUpInside)
        
        sizeImage = UIImageView(image: UIImage(named: "size_button"))
        sizeImage?.isUserInteractionEnabled = true
        sizeImage?.contentMode = .center
        superview?.addSubview(sizeImage!)
        sizeImage?.frame = getCoordinatesOfSizeButton()
        let panGestureRecognizer = UIPanGestureRecognizer(target: sender, action: #selector(EditorViewController.handleSizeImagePan(_:)))
        sizeImage?.addGestureRecognizer(panGestureRecognizer)
    }
    
    func deselect() {
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0.0
        sizeImage?.removeFromSuperview()
        closeButton?.removeFromSuperview()
        copyButton?.removeFromSuperview()
        sizeImage = nil
        closeButton = nil
        copyButton = nil
    }
    
    func addGestureRecognizers(_ sender: AnyObject) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: sender, action: #selector(EditorViewController.handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: sender, action: #selector(EditorViewController.handleSingleTap(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func getCoordinatesOfActionButton(_ corner: Corner) -> CGRect {
        let center = cornerCenter(corner, initialRadius: initialRadiusForSize(image!.size))
        return CGRectMake(center: center, size: CGFloat(Constants.objectActionButtonsSize))
    }
    
    func updateActionButtonsFrames() {
        closeButton?.frame = getCoordinatesOfCloseButton()
        sizeImage?.frame = getCoordinatesOfSizeButton()
        copyButton?.frame = getCoordinatesOfCopyButton()
    }
}

//MARK: - Private

extension SelectableImageView {
    
    fileprivate func initialHeightForSize(_ size: CGSize) -> CGFloat {
        return Constants.initialImageWidth * size.height / size.width
    }
    
    fileprivate func initialRadiusForSize(_ size: CGSize) -> CGFloat {
        return sqrt(pow(Constants.initialImageWidth, 2) + pow(initialHeightForSize(size), 2)) / 2
    }
    
    fileprivate func getCoordinatesOfCloseButton() -> CGRect {
        return getCoordinatesOfActionButton(.topLeft)
    }
    
    fileprivate func getCoordinatesOfSizeButton() -> CGRect {
        return getCoordinatesOfActionButton(.bottomRight)
    }
    
    fileprivate func getCoordinatesOfCopyButton() -> CGRect {
        return getCoordinatesOfActionButton(.topRight)
    }
}

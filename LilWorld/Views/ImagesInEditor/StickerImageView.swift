//
//  StickerImageView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 13/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class StickerImageView: SelectableImageView {

    fileprivate var mirrorButton: UIButton? = nil
    
    fileprivate func getCoordinatesOfMirrorButton() -> CGRect {
        return getCoordinatesOfActionButton(.bottomLeft)
    }
    
    override func selectWithSender(_ sender: AnyObject) {
        super.selectWithSender(sender)
        
        mirrorButton = UIButton(type: .custom)
        mirrorButton?.setImage(UIImage(named: "mirror_button"), for: UIControlState())
        superview?.addSubview(mirrorButton!)
        mirrorButton?.frame = getCoordinatesOfMirrorButton()
        mirrorButton?.addTarget(sender, action: #selector(EditorViewController.mirrorButtonPressed(_:)), for: .touchUpInside)
    }
    
    override func deselect() {
        super.deselect()
        
        mirrorButton?.removeFromSuperview()
        mirrorButton = nil
    }
    
    override func updateActionButtonsFrames() {
        super.updateActionButtonsFrames()
        
        mirrorButton?.frame = getCoordinatesOfMirrorButton()
    }
}

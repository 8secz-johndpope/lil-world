//
//  TextImageView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 07/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class TextImageView: SelectableImageView {

    var textParams: TextParams?
    fileprivate var textEditButton: UIButton? = nil
    
    init (image: UIImage, textParams: TextParams) {
        self.textParams = textParams
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func selectWithSender(_ sender: AnyObject) {
        super.selectWithSender(sender)
        
        textEditButton = UIButton(type: .custom)
        textEditButton?.setImage(UIImage(named: "text_edit_button"), for: UIControlState())
        superview?.addSubview(textEditButton!)
        textEditButton?.frame = getCoordinatesOfTextEditButton()
        textEditButton?.addTarget(sender, action: #selector(EditorViewController.textEditButtonPressed(_:)), for: .touchUpInside)
    }
    
    override func deselect() {
        super.deselect()
        
        textEditButton?.removeFromSuperview()
        textEditButton = nil
    }
    
    override func updateActionButtonsFrames() {
        super.updateActionButtonsFrames()
        
        textEditButton?.frame = getCoordinatesOfTextEditButton()
    }
    
    override func addGestureRecognizers(_ sender: AnyObject) {
        super.addGestureRecognizers(sender)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: sender, action: #selector(EditorViewController.handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    fileprivate func getCoordinatesOfTextEditButton() -> CGRect {
        return getCoordinatesOfActionButton(.bottomLeft)
    }
}

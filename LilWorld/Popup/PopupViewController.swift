//
//  PopupViewController.swift
//  KulaTechEngine
//
//  Created by Aleksandr Novikov on 17/05/16.
//
//

import UIKit
import MZFormSheetPresentationController

open class PopupViewController: UIViewController {

    @IBOutlet weak var scrollView : UIScrollView!
    
    @IBOutlet weak var topImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel! //TTT
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var oneRightButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var buttonsVerticalConstraint: NSLayoutConstraint!
    
    var leftButtonAction: (() -> ())?
    var rightButtonAction: ((_ textFieldText: String?, _ textViewText: String?) -> ())?
    
    fileprivate var scrollsToShowButtons : Bool = true
    
    fileprivate let popupTitle : String
    fileprivate let popupMessage : String
    
    fileprivate let showTextFields : Bool
    
    fileprivate let textFieldPlaceholder : String?
    fileprivate let textViewPlaceholder : String?
    
    fileprivate var leftButtonTitle : String?
    fileprivate var rightButtonTitle : String?
    
    public init(title: String, message: String, textFieldPlaceholder : String?, textViewPlaceholder : String?) {
        popupTitle = title
        popupMessage = message
        
        showTextFields = (textFieldPlaceholder != nil) && (textViewPlaceholder != nil)
        
        self.textFieldPlaceholder = textFieldPlaceholder
        self.textViewPlaceholder = textViewPlaceholder
        
        super.init(nibName: "PopupViewController", bundle: Bundle(identifier: "com.kula-tech.EngineCore"))
    }
    
    public convenience init(title: String, message: String ) {
        self.init(title: title, message: message, textFieldPlaceholder: nil, textViewPlaceholder: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setLeftButtonTitle(_ title: String, action: @escaping () -> ()) {
        leftButtonTitle = title
        leftButtonAction = action
    }
    
    open func setRightButtonTitle(_ title: String, action: @escaping (_ textFieldText: String?, _ textViewText: String?) -> ()) {
        rightButtonTitle = title
        rightButtonAction = action
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        leftButtonAction?()
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        if showTextFields {
            guard let textViewText = textView.text, textViewText.characters.count > 0 else {
                textView.layer.borderColor = UIColor.red.cgColor
                return
            }
            view.endEditing(true)
            rightButtonAction?(textField.text, textViewText)
        } else {
            rightButtonAction?(nil, nil)
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        topImageView.clipsToBounds = true
        topImageView.image = UIImage(named: "lilworld_icon")
        topImageView.layer.cornerRadius = 16
        
        rightButton.setBackgroundImage(UIImage(named: "popup_button_yellow_normal"), for: UIControlState())
        rightButton.setBackgroundImage(UIImage(named: "popup_button_yellow_highlighted"), for: .highlighted)
        oneRightButton.setBackgroundImage(UIImage(named: "popup_button_yellow_normal"), for: UIControlState())
        oneRightButton.setBackgroundImage(UIImage(named: "popup_button_yellow_highlighted"), for: .highlighted)
        leftButton.setBackgroundImage(UIImage(named: "popup_button_gray_normal"), for: UIControlState())
        leftButton.setBackgroundImage(UIImage(named: "popup_button_gray_highlighted"), for: .highlighted)
        
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        
        if #available(iOS 8.3, *) {
            messageLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        } else {
            messageLabel.font = UIFont.systemFont(ofSize: 14)
        }
//        messageLabel.lineSpacing = 3
        
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        oneRightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        titleLabel.text = popupTitle
        messageLabel.text = popupMessage
        
        rightButton.setTitle(rightButtonTitle, for: UIControlState())
        oneRightButton.setTitle(rightButtonTitle, for: UIControlState())
        leftButton.setTitle(leftButtonTitle, for: UIControlState())
        
        if leftButtonTitle == nil {
            rightButton.isHidden = true
            leftButton.isHidden = true
            oneRightButton.isHidden = false
        } else {
            rightButton.isHidden = false
            leftButton.isHidden = false
            oneRightButton.isHidden = true
        }
        
        self.textField.isHidden = !showTextFields
        self.textView.isHidden = !showTextFields
        
        self.buttonsVerticalConstraint.constant = showTextFields ? 215 : 28
        
        textField.placeholder = textFieldPlaceholder
        textField.layer.borderColor = UIColor(white: 230/255, alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.delegate = self
        
        textView.layer.borderColor = UIColor(white: 230/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.delegate = self
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PopupViewController.hideKeyboard)))
        
        navigationItem.title = NSLocalizedString("settings_support_label", tableName: "Appirater", bundle: Bundle.main, value: "", comment: "")
    }
    
    @objc fileprivate func hideKeyboard() {
        if scrollsToShowButtons {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        self.view.endEditing(true)
    }
    
    open func formSheetViewController() -> MZFormSheetPresentationViewController {
        let popupFormSheet = MZFormSheetPresentationViewController(contentViewController: self)
        popupFormSheet.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.dropDown
        popupFormSheet.presentationController?.shouldCenterVertically = true
        popupFormSheet.presentationController?.shouldCenterHorizontally = true
        popupFormSheet.presentationController?.movementActionWhenKeyboardAppears = .alwaysAboveKeyboard
        
        self.scrollsToShowButtons = false
        
        if !showTextFields {
            popupFormSheet.presentationController?.contentViewSize = CGSize(width: UIScreen.main.bounds.size.width - 24, height: 320)
        } else {
            popupFormSheet.presentationController?.contentViewSize = CGSize(width: UIScreen.main.bounds.size.width - 24, height: 480)
        }
        return popupFormSheet
    }
}

extension PopupViewController : UITextFieldDelegate, UITextViewDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if scrollsToShowButtons {
//            if DeviceType.IS_IPAD && interfaceOrientation.isPortrait {
//                scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
//            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - 20), animated: true)
//            }
        }
        return true
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if scrollsToShowButtons {
//            if DeviceType.IS_IPAD && interfaceOrientation.isPortrait {
//                scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
//            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - 20), animated: true)
//            }
        }
        return true
    }
}

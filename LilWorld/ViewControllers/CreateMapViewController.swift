//
//  CreateMapViewController.swift
//  ArtMosSphere
//
//  Created by Aleksandr Novikov on 08.07.16.
//  Copyright © 2016 Kula Tech. All rights reserved.
//

import UIKit
import Photos
import MagicalRecord
import Alamofire

class CreateMapViewController: UIViewController {

    lazy var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var chooseImageLabel: UILabel!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: InsetFloatLabelTextField!
    @IBOutlet weak var emailTextField: InsetFloatLabelTextField!
    @IBOutlet weak var phoneNumberTextField: InsetFloatLabelTextField!
    @IBOutlet weak var imageUploadView: ImageUploadView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var rulesLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var thankYouView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.backgroundColor = UIColor(red: 0.58, green: 0.68, blue: 0.9, alpha: 1)
        
        titleLabel.attributedText = NSAttributedString(string: localized("Contest_submit_title"), attributes: GlobalConstants.kTitleAttributes)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateMapViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        imageUploadView.delegate = self
        
        nameTextField.addTarget(self, action: #selector(CreateMapViewController.textFieldValueDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(CreateMapViewController.textFieldValueDidChange), for: .editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(CreateMapViewController.textFieldValueDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMapViewController.keyboardWillChangeFrameNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let font : UIFont
        if #available(iOS 8.3, *) {
            font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightMedium)
        } else {
            font = UIFont.systemFont(ofSize: 10)
        }
        
        let rulesText = NSMutableAttributedString(string: "Нажимая «Участвовать в конкурсе», Вы соглашаетесь с ", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(white: 153/255, alpha: 1)])
        rulesText.append(NSAttributedString(string: "условиями проведения конкурса", attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor(red: 89/255, green: 152/255, blue: 225/255, alpha: 1)]))
        
        rulesLabel.attributedText = rulesText
        rulesLabel.isUserInteractionEnabled = true
        rulesLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateMapViewController.rulesLabelPressed)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func VKButtonPressed(_ sender: UIButton) {
        showModalWebBrowserWithURL(URL(string: "https://vk.com/kinder")!)
    }
    
    @IBAction func OKButtonPressed(_ sender: AnyObject) {
        showModalWebBrowserWithURL(URL(string: "https://ok.ru/kinder")!)
    }
    
    func rulesLabelPressed() {
        performSegue(withIdentifier: "showRules", sender: self)
        showModalWebBrowserWithURL(URL(string: "http://contest.lil.city/rules/")!)
    }
    
    @IBAction func closeButtonPressed() {
        performSegue(withIdentifier: "createMapCancel", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRules" {
            let destination = segue.destination as! AboutContestViewController
            destination.showCloseButton = true
            destination.urlToOpen = "http://contest.lil.city/rules/"
        }
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        uploadImageToServer()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func openImagePickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType, allowsEditing:Bool) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = allowsEditing
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadImageButtonPressed(_ sender: UIButton?) {
        openImagePickerWithSourceType(.photoLibrary, allowsEditing: false)
    }
    
    func uploadImageToServer() {
        view.endEditing(true)
        imageUploadView.startLoading()
        imageUploadView.isHidden = false
        weak var weakSelf = self
        
        guard let name = nameTextField.text, name.characters.count > 0 else {
            showAlertWithMessage("Пожалуйста, укажите Ваше имя")
            return
        }
        
        guard let email = emailTextField.text, email.characters.count > 0 else {
            showAlertWithMessage("Пожалуйста, укажите Ваш email адрес")
            return
        }
        
        guard let phoneNumber = phoneNumberTextField.text, phoneNumber.characters.count > 0 else {
            showAlertWithMessage("Пожалуйста, укажите Ваш номер телефона")
            return
        }
        
        guard let image = mapImage.image else {
            showAlertWithMessage("Пожалуйста, загрузите Вашу работу")
            return
        }
        
        loadingView.alpha = 0
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { 
            weakSelf?.loadingView.alpha = 0.5
            }, completion: nil)
        
        LilWorldAPIClient.uploadContestImage(["image" : image, "name" : name, "email" : email, "phone" : phoneNumber], successBlock: {
            if weakSelf != nil {
                weakSelf?.thankYouView.alpha = 0
                weakSelf?.thankYouView.isHidden = false
                UIView.animate(withDuration: 0.2, animations: { 
                    weakSelf?.thankYouView.alpha = 1
                    }, completion: nil)
            }
            }) {
                let alertController = UIAlertController(title: "Не удалось отправить заявку", message: "Пожалуйста, проверьте Ваше подключение к интернету и попробуйте ещё раз", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title:
                    "Отменить", style: .cancel, handler: { (action) in
                    weakSelf?.loadingView.isHidden = true
                }))
                alertController.addAction(UIAlertAction(title: "Повторить попытку", style: .default, handler: { (action) in
                    weakSelf?.uploadImageToServer()
                }))
                weakSelf?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertWithMessage(_ message : String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func isValidEmail(_ email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

//}

extension CreateMapViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageUploadView.beforeLoading()
            mapImage.image = image
            updateSubmitButton()
            imageUploadView.isHidden = false
            chooseImageButton.isHidden = true
            chooseImageLabel.isHidden = true
            dismiss(animated: true, completion: nil)
        }
    }
}

extension CreateMapViewController : ImageUploadViewDelegate {
    
    func uploadViewRemoveButtonPressed(_ sender : ImageUploadView) {
        
        imageUploadView.isHidden = true
        chooseImageButton.isHidden = false
        chooseImageLabel.isHidden = false
        mapImage.image = nil
        updateSubmitButton()
    }
    
    func uploadViewReloadButtonPressed(_ sender : ImageUploadView) {
        uploadImageToServer()
    }
}

//Keyboard notifications
extension CreateMapViewController {
    func keyboardWillChangeFrameNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
//            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
//            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)

            let bottomOffset = endFrame?.origin.y ?? 0
            var holeSize = bottomOffset - view.frame.origin.y - 80
            
            if nameTextField.isEditing  {
                if nameTextField.frame.maxY - scrollView.contentOffset.y > holeSize {
                    scrollView.setContentOffset(CGPoint(x: 0, y: nameTextField.frame.maxY - holeSize), animated: true)
                }
            }
            if emailTextField.isEditing {
                if emailTextField.frame.maxY - scrollView.contentOffset.y > holeSize {
                    scrollView.setContentOffset(CGPoint(x: 0, y: emailTextField.frame.maxY - holeSize), animated: true)
                }
            }
            
            holeSize -= 40
            
            if phoneNumberTextField.isEditing {
                if phoneNumberTextField.frame.maxY - scrollView.contentOffset.y > holeSize {
                    scrollView.setContentOffset(CGPoint(x: 0, y: phoneNumberTextField.frame.maxY - holeSize), animated: true)
                }
            }
        }
    }
}

extension CreateMapViewController : UITextFieldDelegate {
    
    func textFieldValueDidChange(_ textField: UITextField) {
        updateSubmitButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            phoneNumberTextField.becomeFirstResponder()
        } else {
            uploadImageToServer()
        }
        return true
    }
    
    func updateSubmitButton() {
        let nameLength = nameTextField.text?.characters.count ?? 0
        let emailLength = emailTextField.text?.characters.count ?? 0
        let phoneLength = phoneNumberTextField.text?.characters.count ?? 0
        
        submitButton.isEnabled = mapImage.image != nil && nameLength > 0 && emailLength > 0 && phoneLength > 0
    }
}

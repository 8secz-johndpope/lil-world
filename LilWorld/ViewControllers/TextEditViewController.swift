//
//  TextEditViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 04/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

protocol TextEditViewControllerDelegate {
    func textEditViewControllerDoneWithImage(_ image: UIImage, textParams: TextParams)
}

class TextEditViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fontsPicker: FontsPickerView!
    @IBOutlet weak var fontsPointer: UIImageView!
    @IBOutlet weak var colorToolsContainer: UIView!
    @IBOutlet weak var fontsToolsContainer: UIView!
    @IBOutlet weak var fixView: UIView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var fontsButton: UIButton!
    @IBOutlet weak var opacitySlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var colorsSlider: UISlider!
    @IBOutlet weak var colorsSliderBackgroundImage: UIImageView!
    @IBOutlet weak var opacitySliderBackgroundImage: UIImageView!
    @IBOutlet weak var brightnessSliderBackgroundImage: UIImageView!
    
    var textParams: TextParams? = nil
    var delegate: TextEditViewControllerDelegate?
    
    deinit {
        textView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.addObserver(self, forKeyPath:"contentSize", options:[.new,.initial], context:nil)
        textView.becomeFirstResponder()
        fontsPicker.fontsPickerDelegate = self
        fontsPointer.image = UIImage(named: "font_pointer")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 50, 0, 50), resizingMode: .stretch)
        
        colorButton.isSelected = true
        colorToolsContainer.bringToFront()
        fixLayers()
        
        colorsSliderBackgroundImage.image = UIImage(named: "colors_slider_background")
        opacitySliderBackgroundImage.image = UIImage(named: "opacity_slider_background")
        brightnessSliderBackgroundImage.image = UIImage(named: "brightness_slider_background")
        colorsSlider.setupForEditTextController()
        opacitySlider.setupForEditTextController()
        brightnessSlider.setupForEditTextController()
    
        updateTextColorWithSlidersValues()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fontsPicker.currentFontName = textParams?.fontName ?? "SensaBrush-Fill"
        
        if let textParams = textParams {
            var hue:CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            textParams.textColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            opacitySlider.value = 1 - Float(alpha)
            colorsSlider.value = Float(hue)
            if brightness == 1 {
                brightnessSlider.value = 1 - Float(saturation) * 0.5
            } else {
                brightnessSlider.value = Float(brightness) * 0.5
            }
            textView.text = textParams.text
        } else {
            textView.text = " "
            updateTextColorWithSlidersValues()
            textView.text = ""
        }
        updateTextColorWithSlidersValues()
    }
}

//MARK: - Private

extension TextEditViewController {
    
    fileprivate func sizeOfString (_ string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: DBL_MAX),
                                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                         attributes: [NSFontAttributeName: font],
                                                         context: nil).size
    }
    
    fileprivate func updateTextViewContentOffset() {
        
        var topInset: CGFloat = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0
        if topInset < 0 {
            topInset = 0
        }
        self.textView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0)
    }
    
    fileprivate func currentColor() -> UIColor {
        if brightnessSlider.value <= 0.5 {
            return UIColor(hue: CGFloat(colorsSlider.value), saturation: 1, brightness: CGFloat(brightnessSlider.value * 2), alpha: CGFloat(1 - opacitySlider.value))
        } else {
            return UIColor(hue: CGFloat(colorsSlider.value), saturation: CGFloat(1 - brightnessSlider.value) * 2, brightness: 1, alpha: CGFloat(1 - opacitySlider.value))
        }
        
    }
    
    fileprivate func updateTextColorWithSlidersValues() {
        textView.textColor = currentColor()
    }
    
    fileprivate func fixLayers() {
        fixView.bringToFront()
        colorButton.bringToFront()
        fontsButton.bringToFront()
    }
    
    fileprivate func showAlertNoText() {
        let alertController = UIAlertController(title: localized("Alerts_emptyTextErrorTitle"), message: localized("Alerts_emptyTextErrorMessage"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Actions

extension TextEditViewController {
    
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        colorButton.isSelected = true
        fontsButton.isSelected = false
        colorToolsContainer.bringToFront()
        fixLayers()
    }
    
    @IBAction func fontsButtonPressed(_ sender: UIButton) {
        colorButton.isSelected = false
        fontsButton.isSelected = true
        fontsToolsContainer.bringToFront()
        fixLayers()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateTextColorWithSlidersValues()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        
        guard let text = textView.text, let textLength = textView.text?.characters.count, textLength != 0 else {
            showAlertNoText()
            return
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSFontAttributeName: UIFont(name: fontsPicker.currentFontName!, size: textLength < 50 ? 150 : 100)!,
            NSForegroundColorAttributeName: textView.textColor!,
            NSParagraphStyleAttributeName: paragraphStyle
        ] as [String: AnyObject]
        let size = (text as NSString).size(attributes: attributes)
        if (size.width == 0 || size.height == 0) {
            showAlertNoText()
            return
        }
        let textImage = UIImage.imageWithString(text as NSString, attributes: attributes, size: size)
        self.delegate?.textEditViewControllerDoneWithImage(textImage, textParams: TextParams(text: textView.text, fontName: fontsPicker.currentFontName!, textColor: textView.textColor!))
        self.mz_formSheetPresentingPresentationController()?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.mz_formSheetPresentingPresentationController()?.dismiss(animated: true, completion: nil)
    }
}


//MARK: - KVO

extension TextEditViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? UITextView {
            updateTextViewContentOffset()
        }
    }
}

//MARK: - UISlider setup

extension UISlider {
    
    func setupForEditTextController() {
        self.setMaximumTrackImage(nil, for: UIControlState())
        self.setMinimumTrackImage(nil, for: UIControlState())
        self.maximumTrackTintColor = UIColor.clear
        self.minimumTrackTintColor = UIColor.clear
        self.setThumbImage(UIImage(named: "pointer_medium"), for: UIControlState())
        self.setThumbImage(UIImage(named: "pointer_medium"), for: .highlighted)
    }
}

//MARK: - FontsPickerViewDelegate

extension TextEditViewController: FontsPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectFontWithName fontName: String) {
        textView.font = UIFont(name: fontName, size: 50)
    }
}

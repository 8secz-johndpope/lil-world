//
//  FontsPickerView.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 04/04/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class FontsPickerView: UIPickerView {

    var fontsPickerDelegate: FontsPickerViewDelegate?
    var fontSize: CGFloat = 20.0
    var fontNames: [String] = {
        return [
            "BadScript-Regular",
            "BERNIERShade-Regular",
            "BloggerSans-Light",
            "BukhariScript-Regular",
            "Freeride",
            "Frenchpress",
            "Gagalin-Regular",
            "GOGOIA-Deco",
            "Gogol",
            "GUERRILLA-Normal",
            "LeOsler-RoughRegular",
            "NexaRustExtras-Free",
            "Nickainley-Normal",
            "Oranienbaum",
            "Perfograma",
            "PTNewYear2015",
            "SensaBrush-Fill",
            "SensaPen-Regular",
            "SensaSans-Regular",
            "SensaSerif-Regular",
            "SensaWild-Line",
            "SensaWild-Fill",
            "SensaWild-DotOutlineShade",
            "SensaWild-Outline",
            "SensaWild-Dot",
            "Sensei-Medium",
            "SummerFont-Light",
            "Sunday-Regular",
            "Yarin-Regular",
            "Yarin-Bold",
            "ALSZet-Light"
        ]
    }()
    
    var rowHeight: CGFloat = 28.0
    
    fileprivate var currentFontIndex = 0
    var currentFontName: String? {
        set {
            if let fontName = newValue,
                   let fontIndex = fontNames.index(of: fontName) {
                currentFontIndex = fontIndex
            } else {
                currentFontIndex = 0
            }
            selectRow(currentFontIndex, inComponent: 0, animated: false)
            pickerView(self, didSelectRow: currentFontIndex, inComponent: 0)
            
        }
        get {
            return fontNames[safe: currentFontIndex]
        }
    }
    
//MARK: - Initializers
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

//MARK: - Private

extension FontsPickerView {
    
    fileprivate func setup() {
        self.delegate = self
        self.dataSource = self
    }
}

//MARK: - UIPickerViewDelegate

extension FontsPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let fontLabel = UILabel()
        fontLabel.font = UIFont(name:fontNames[row], size: fontSize)!
        fontLabel.textColor = UIColor.white
        fontLabel.text = fontNames[row]
        fontLabel.textAlignment = .center
        return fontLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fontsPickerDelegate?.pickerView(self, didSelectFontWithName: fontNames[row])
        currentFontIndex = row
    }
    
}

//MARK: - UIPickerViewDataSource

extension FontsPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNames.count
    }
}

//MARK: - FontsPickerViewDelegate protocol

protocol FontsPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectFontWithName fontName: String)
}

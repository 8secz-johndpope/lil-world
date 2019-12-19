//
//  AboutViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 24/08/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit
import SWRevealViewController

class AboutViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aboutAppLabel: UILabel!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var madeInTheLabel: UILabel!

    @IBAction func lilCityButtonPressed(_ sender: AnyObject) {
        showModalWebBrowserWithURL(URL(string: "http://lil.city")!)
    }
    
    @IBAction func instagramButtonPressed(_ sender: UIButton) {
        showModalWebBrowserWithURL(URL(string: "http://instagram.com/lilworldapp/")!)
    }
    
    @IBAction func termsOfUseButtonPressed(_ sender: AnyObject) {
        showModalWebBrowserWithURL(URL(string: "http://terms.lil.city")!)
    }
}

//MARK: - Lifecycle

extension AboutViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.attributedText = NSAttributedString(string: localized("About_title"), attributes: GlobalConstants.kTitleAttributes)
        
        madeInTheLabel.font = UIFont(name: "Circe-Regular", size: 10)!
        madeInTheLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        
        let smallParagraphStyle = NSMutableParagraphStyle()
        smallParagraphStyle.lineSpacing = 3
        smallParagraphStyle.alignment = .center
        let smallLabelsAttributes = [
            NSFontAttributeName: UIFont(name: "Circe-Regular", size: 10)!,
            NSForegroundColorAttributeName: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0),
            NSParagraphStyleAttributeName: smallParagraphStyle
        ]
        let bigLabelsAttributes = [
            NSFontAttributeName: UIFont(name: "Circe-Light", size: 17)!,
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let biggestParagraphStyle = NSMutableParagraphStyle()
        biggestParagraphStyle.lineSpacing = 16
        biggestParagraphStyle.alignment = .center
        let biggestLabelsAttributes = [
            NSFontAttributeName: UIFont(name: "Circe-Light", size: 25)!,
            NSForegroundColorAttributeName: UIColor.black,
            NSParagraphStyleAttributeName: biggestParagraphStyle
        ]
        let lilworldString = NSAttributedString(string: "#lilworld\n", attributes: biggestLabelsAttributes)
        let illustrationString = NSAttributedString(string: "FOUNDER\n", attributes: smallLabelsAttributes)
        let letteringString = NSAttributedString(string: "LETTERING\n", attributes: smallLabelsAttributes)
        let instagramString = NSAttributedString(string: "INSTAGRAM", attributes: smallLabelsAttributes)
        let illustratorNameString = NSAttributedString(string: "Sasha Kru\n\n", attributes: bigLabelsAttributes)
        let letteringNameString = NSAttributedString(string: "Varya Che, Nika Ewan\n\n", attributes: bigLabelsAttributes)
        
        let aboutAppString = NSMutableAttributedString()
        aboutAppString.append(lilworldString)
        aboutAppString.append(illustrationString)
        aboutAppString.append(illustratorNameString)
        aboutAppString.append(letteringString)
        aboutAppString.append(letteringNameString)
        aboutAppString.append(instagramString)
        aboutAppLabel.attributedText = aboutAppString
        
        
        if self.revealViewController() != nil {
            sideMenuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        }
    }
}

//
//  ContestPopupViewController.swift
//  LilWorld
//
//  Created by Aleksandr Novikov on 11.08.16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class ContestPopupViewController: UIViewController {

    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var betweenConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if DeviceType.IS_IPHONE_4_OR_LESS {
            popupImageView.image = UIImage(named: "contest_background_4")
            bottomConstraint.constant = 12
        } else if DeviceType.IS_IPHONE_5 {
            popupImageView.image = UIImage(named: "contest_background_5")
            bottomConstraint.constant = 64
        } else if DeviceType.IS_IPHONE_6 {
            popupImageView.image = UIImage(named: "contest_background_6")
            bottomConstraint.constant = 76
            betweenConstraint.constant = 16
        } else if DeviceType.IS_IPHONE_6P {
            popupImageView.image = UIImage(named: "contest_background_6plus")
            bottomConstraint.constant = 86
            betweenConstraint.constant = 20
        }
        
    }
    
    @IBAction func aboutButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "contestInfo", sender: self)
    }

    @IBAction func skipButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  SocialPostTableViewCell.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 16/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class SocialPostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postImageHeightConstraint: NSLayoutConstraint!

    override func prepareForReuse() {
        usernameButton.setTitle("", for: UIControlState())
        usernameButton.setTitle("", for: .highlighted)
        postImage.sd_cancelCurrentImageLoad()
        postImage.image = nil
    }
}

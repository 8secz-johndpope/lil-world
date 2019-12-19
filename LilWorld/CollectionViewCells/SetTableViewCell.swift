//
//  SetTableViewCell.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 03/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {

    @IBOutlet weak var setImageView: URLImageView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setDescriptionLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var buyingActivityIndicator: UIActivityIndicatorView!
    
    var productId: String? = nil
    
    override func prepareForReuse() {
        setImageView.prepareForReuse()
    }
}

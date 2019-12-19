//
//  FourthCollectionViewCell.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 07/09/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit

class ThirdLevelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: URLImageView!
    var available: Bool = true
    var productId: String? = nil
    
    override func prepareForReuse() {
        imageView.prepareForReuse()
    }
}

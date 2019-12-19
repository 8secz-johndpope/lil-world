//
//  SecondLevelCollectionViewCell.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 04/09/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit

class SecondLevelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        imageView.prepareForReuse()
    }
}

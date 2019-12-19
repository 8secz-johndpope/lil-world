//
//  SetCollectionViewCell.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 10/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class SetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stickerImageView: URLImageView!
    
    override func prepareForReuse() {
        stickerImageView.prepareForReuse()
    }
}

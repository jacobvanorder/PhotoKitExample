//
//  PhotoCollectionViewCollectionViewCell.swift
//  PhotoKitExample
//
//  Created by mrJacob on 6/30/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var mainImageView: UIImageView
    
    let cellSize : CGSize = {
       return CGSizeMake(100.0, 100.0)
    }()

}

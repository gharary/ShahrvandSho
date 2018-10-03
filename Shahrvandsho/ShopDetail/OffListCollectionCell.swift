//
//  OffListCollectionCell.swift
//  Shahrvandsho
//
//  Created by Mohammad Gharari on 11/15/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit

class OffListCollectionCell: UICollectionViewCell {
    @IBOutlet weak var offItemImage: UIImageView!
    
    @IBOutlet weak var offItemLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 10 //self.frame.size.width * 0.200
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
    }

    
}

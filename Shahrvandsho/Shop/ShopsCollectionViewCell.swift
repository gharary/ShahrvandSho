//
//  ShopsCollectionViewCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class ShopsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shopImage: UIImageView!
    
    @IBOutlet weak var shopLocation: UILabel!
    @IBOutlet weak var shopName: UILabel!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.size.width * 0.100
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
    }
 
    
    
    
    
    
    
    
    
    
}

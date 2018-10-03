//
//  ShowSelfieCollectionCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 11/9/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class ShowSelfieCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var selfieLocation: UILabel!
    @IBOutlet weak var selfiePhotographer: UILabel!
    @IBOutlet weak var selfieLike: UIImageView!
    @IBOutlet weak var selfieLikeNo:UILabel!
    @IBOutlet weak var selfieLikeBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = self.frame.size.width * 0.100
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
    }
    
}

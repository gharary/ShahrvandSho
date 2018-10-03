//
//  OffItemTableViewCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/22/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class OffItemTableViewCell: UITableViewCell {

    @IBOutlet weak var shopOffPercent: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    var shops:Shops? {
        didSet {
            if let theShop = shops {
                shopImage.image = UIImage(named: theShop.image)
                shopName.text = theShop.name
                shopOffPercent.text = theShop.percent
                /*shopImage.layer.cornerRadius = shopImage.bounds.height / 2
                shopImage.clipsToBounds = true
                //shopImage.layer.cornerRadius = 10*/
            }
        }
    }
}

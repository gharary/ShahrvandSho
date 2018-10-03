//
//  OffItemTableViewCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/22/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class searchItemCell: UITableViewCell {

    @IBOutlet weak var shopLocation: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    var shops:Shops? {
        didSet {
            if let theShop = shops {
                shopImage.image = UIImage(named: theShop.image)
                shopName.text = theShop.name
                shopLocation.text = theShop.percent
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}

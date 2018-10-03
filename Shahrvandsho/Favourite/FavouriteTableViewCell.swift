//
//  FavouriteTableViewCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/11/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {

    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shoLocation:UILabel!
    
    @IBOutlet weak var shopImage:UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

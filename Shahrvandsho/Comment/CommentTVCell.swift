//
//  CommentTVCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class CommentTVCell: UITableViewCell {
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var subject:UILabel!
    @IBOutlet weak var comment:UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

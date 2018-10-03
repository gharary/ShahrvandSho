//
//  JobSeekTableViewCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class JobSeekTableViewCell: UITableViewCell {

    @IBOutlet weak var jobSeekImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var degree: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

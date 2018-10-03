//
//  EmployTableViewCell.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class EmployTableViewCell: UITableViewCell {

    @IBOutlet weak var jobSalary: UILabel!
    @IBOutlet weak var jobWorkTime: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var employImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

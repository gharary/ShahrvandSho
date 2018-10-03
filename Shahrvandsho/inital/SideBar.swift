//
//  SideBar.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/10/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class SideBar: UITableViewController {

    let defaults = UserDefaults.standard
    @IBOutlet weak var adminCell:UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let isLoggedIn = defaults.bool(forKey: "isLoggenIn")
        print("is loggen in: \(isLoggedIn)")
        if isLoggedIn  {
            adminCell.isUserInteractionEnabled = true
            adminCell.alpha = 1.0
            adminCell.contentView.alpha = 1.0
        }
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //defaults.set(true, forKey: "isLoggenIn")
    }

}

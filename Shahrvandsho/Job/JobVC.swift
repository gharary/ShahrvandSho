//
//  JobVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class JobVC: UIViewController {
    @IBOutlet weak var Employer: UIView!

    @IBOutlet weak var segmentetControl: UISegmentedControl!
    @IBOutlet weak var employee: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "استخدامی"
    }

    @IBAction func indexValueChanged(_ sender: UISegmentedControl) {
        
        switch segmentetControl.selectedSegmentIndex  {
        case 0:
            Employer.isHidden = true
            employee.isHidden = false
        case 1:
            Employer.isHidden = false
            employee.isHidden = true
        default:
            break
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        title = "استخدامی"
    }
    override func viewWillAppear(_ animated: Bool) {
        title = "استخدامی"
    }
    

}

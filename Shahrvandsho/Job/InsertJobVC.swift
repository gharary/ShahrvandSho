//
//  InsertJobVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/14/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class InsertJobVC: UIViewController {

    @IBOutlet weak var Seeker: UIView!
    
    @IBOutlet weak var segmentetControl: UISegmentedControl!
    @IBOutlet weak var Employer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "استخدامی"
    }
    
    @IBAction func returnBtn(_ sender: Any) {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstView") as UIViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        self.present(viewController, animated: false, completion: nil)
        //self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func indexValueChanged(_ sender: UISegmentedControl) {
        
        switch segmentetControl.selectedSegmentIndex  {
        case 1:
            Seeker.isHidden = true
            Employer.isHidden = false
        case 0:
            Seeker.isHidden = false
            Employer.isHidden = true
        default:
            break
        }
    }
}

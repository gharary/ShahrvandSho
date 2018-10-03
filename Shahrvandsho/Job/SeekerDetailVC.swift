//
//  SeekerDetailVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/15/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class SeekerDetailVC: UIViewController {
    
    
    @IBOutlet weak var jobTitle:UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age:UILabel!
    @IBOutlet weak var education: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var explain:UILabel!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var educationView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var explainView: UIView!
    
    
    
    
    @IBAction func returnBtn(_ sender: Any) {

    }

    
    var titleStr = "."
    var nameStr = "-"
    var ageStr = "-"
    var educationStr = "-"
    var mobileStr = "-"
    var paymentStr = "-"
    var explainStr = "-"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //titleView.layer.cornerRadius = 10
        nameView.layer.cornerRadius = 10
        ageView.layer.cornerRadius = 10
        educationView.layer.cornerRadius = 10
        phoneView.layer.cornerRadius = 10
        paymentView.layer.cornerRadius = 10
        explainView.layer.cornerRadius = 10
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        let tLabel = UILabel(frame: frame)
        tLabel.text = titleStr
        tLabel.textColor = UIColor.white
        tLabel.font = UIFont(name: "IRANSANSMOBILE-Light", size: 16)
        tLabel.backgroundColor = UIColor.clear
        tLabel.adjustsFontSizeToFitWidth = true
        tLabel.textAlignment = .center
        
        self.navigationController?.navigationBar.topItem?.title = ""
        let backImage = UIImage(named: "back.jpg")
        self.navigationItem.titleView = tLabel
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        //self.navigationController?.navigationBar.topItem?.titleView = tLabel
        //jobTitle.text = titleStr
        name.text = nameStr
        age.text = ageStr
        education.text = educationStr
        mobile.text = mobileStr
        payment.text = paymentStr
        explain.text = explainStr
        explain.sizeToFit()
        title = titleStr
        
//        explain.numberOfLines = 0
//        explain.lineBreakMode = NSLineBreakMode.byWordWrapping
//        explain.frame.size.height = CGFloat(MAXFLOAT)
//        explain.sizeToFit()
//        explainView.frame.size.height = explain.frame.size.height + 20.0
        
        // Do any additional setup after loading the view.
    }

    

}

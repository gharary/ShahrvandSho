//
//  EmplyerDetailVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/15/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class EmplyerDetailVC: UIViewController {

    
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var workTime: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var Payment: UILabel!
    @IBOutlet weak var Explain: UILabel!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var explainView: UIView!
    
    var titleStr = ""
    var timeStr = ""
    var phoneStr = ""
    var mobileStr = ""
    var paymentStr = ""
    var explainStr = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //titleView.layer.cornerRadius = 10
        timeView.layer.cornerRadius = 10
        phoneView.layer.cornerRadius = 10
        mobileView.layer.cornerRadius = 10
        paymentView.layer.cornerRadius = 10
        explainView.layer.cornerRadius = 10
        
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        title = titleStr
        //jobTitle.text = titleStr
        workTime.text = timeStr
        phone.text = phoneStr
        mobile.text = mobileStr
        Payment.text = paymentStr
        Explain.text = explainStr
        

        // Do any additional setup after loading the view.
    }

}

//
//  AboutUsViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/19/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var mailusBtn:UIButton!
    @IBOutlet weak var callUsBtn:UIButton!
    @IBOutlet weak var AboutUsText: UITextView!
    
    
    
    @IBAction func openTelegram(_ sender: Any) {
        
        var telegram = URL(string: "telegram://resolve?domain=shahrvandsho")!
        
        if UIApplication.shared.canOpenURL(telegram) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(telegram, options: ["":""], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            //Telegram not Installed
            telegram = URL(string: "t.me/Shahrvandsho")!
            UIApplication.shared.openURL(telegram)
            
        }
    }
    
    
    @IBAction func openInstagram(_ sender: Any) {
        var instagram = URL(string: "instagram://user?username=shahrvandsho")!
        
        if UIApplication.shared.canOpenURL(instagram) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(instagram, options: ["":""], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            //Telegram not Installed
            instagram = URL(string: "instagram.com/shahrvandsho.ir")!
            UIApplication.shared.openURL(instagram)
            
        }
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "درباره ما"
        AboutUsText.font = UIFont(name: "IRANSansMobile", size: 16)
        mailusBtn.layer.cornerRadius = 10
        callUsBtn.layer.cornerRadius = 10
        
        // Do any additional setup after loading the view.
        
        
    }


}

//
//  SupportViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/19/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class SupportViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var qestionView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var supportView: UIView!
    
    @IBAction func returnBtn(_ sender: Any) {
        /*
         let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstView") as UIViewController
        
        self.present(viewController, animated: false, completion: nil)
         */
        //performSegueToReturnBack()
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func callSupport(_ sender: Any) {
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
            UIApplication.shared.open(telegram, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func questionBtn(_ sender: Any) {
        //print(" question Clicked ")
        if let url = URL(string: "http://shahrvandsho.ir") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
                //UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    @IBAction func guideBtn(_ sender: Any) {

    }
    
    
    @IBAction func emailBtn(_ sender: Any) {
        //print("کلید ایمیل کلیک خورد")
        if !MFMailComposeViewController.canSendMail() {
            //print("سرویس ایمیل فعال نیست")
            showAlert()
            return
        }
        
        sendEmail()
    }
    func showAlert() {
        let alert = UIAlertController(title: "خطا", message: "سرویس ارسال ایمیل بر روی دستگاه شما فعال نیست", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func sendEmail() {
    
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        // Configure the fields of the interface.
        mail.setToRecipients(["gharary.dev@icloud.com"])
        mail.setSubject("شهروندشو")
        //composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
        // Present the view controller modally.
        self.present(mail, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.layer.cornerRadius = 10
        infoView.layer.borderColor = UIColor(red: 239.0/255.0 , green: 239/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor
        infoView.layer.borderWidth = 3
        
        qestionView.layer.cornerRadius = 10
        qestionView.layer.borderColor = UIColor(red: 239.0/255.0 , green: 239/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor
        qestionView.layer.borderWidth = 3

        supportView.layer.cornerRadius = 10
        supportView.layer.borderColor = UIColor(red: 239.0/255.0 , green: 239/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor
        supportView.layer.borderWidth = 3

        emailView.layer.cornerRadius = 10
        emailView.layer.borderColor = UIColor(red: 239.0/255.0 , green: 239/255.0, blue: 244.0/255.0, alpha: 1.0).cgColor
        emailView.layer.borderWidth = 3
        
        self.title = "پشتیبانی"

        // Do any additional setup after loading the view.
    }

}

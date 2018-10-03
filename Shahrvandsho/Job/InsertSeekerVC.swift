//
//  InsertSeekerVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/14/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import HKProgressHUD

class InsertSeekerVC: UIViewController {
    
    @IBOutlet weak var scrolView:UIScrollView!
    let url = URL(string: "http://shahrvandsho.ir/api/seeker")
    
    
    @IBOutlet weak var ageTxTField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var degreeTxtField: UITextField!
    @IBOutlet weak var jobTxtField: UITextField!
    @IBOutlet weak var mobileTxtField: UITextField!
    @IBOutlet weak var explainTxtField: UITextField!
    @IBOutlet weak var salaryTxTField: UITextField!
    @IBOutlet weak var submitButton:UIButton!
    
    
    var hud = HKProgressHUD()
    @IBAction func submitBtn(_ sender: Any) {
        DispatchQueue.main.async {
            
            self.hud = HKProgressHUD.show(addedToView: (self.view)!, animated: true)
            self.hud.label?.text = NSLocalizedString("در حال بارگذاری...", comment: "لطفا صبر کنید...")
        }
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let name = nameTxtField.text!
        let degree = degreeTxtField.text!
        let jobTitle = jobTxtField.text!
        let mobile = mobileTxtField.text!
        let explain = explainTxtField.text!
        let age = ageTxTField.text!
        let salary = salaryTxTField.text!
        
        let postString = "name=\(name)&age=\(age)&education=\(degree)&tell=\(mobile)&job=\(jobTitle)&desc=\(explain)&salary=\(salary)"
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            guard let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 else {
                // check for http errors
                let alert = UIAlertController(title: "", message: "در حال حاضر خطایی رخ داد. لطفا مجددا سعی کنید.!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(String(describing: response))")
                
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                
                _ = HKProgressHUD.hide(addedToView: (self.view), animated: true)
                let alert = UIAlertController(title: "", message: "آگهی شما با موفقیت ثبت شد!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            print("responseString = \(String(describing: responseString))")
            
        }
        task.resume()
        //view.endEditing(true)

        
    }
    
    var keyStatus = false
    @objc func keyboardWillShow(notification : NSNotification) {
        if !keyStatus {
            
            keyStatus=true
            adjustInsetForkeyboardShow(show: true, notification:  notification)
        }
        
    }
    @objc func keyboardWillHide( notification : NSNotification) {
        if keyStatus {
            keyStatus=false
            adjustInsetForkeyboardShow(show: false, notification: notification )
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func adjustInsetForkeyboardShow ( show: Bool , notification : NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyoardFrame = ( userInfo [ UIKeyboardFrameBeginUserInfoKey]as! NSValue).cgRectValue
        
        var adjustmentHeight = ( keyoardFrame.height * ( show ? 1 : -1 ) )
        
        if (keyStatus) {
            adjustmentHeight += 30
        }
        else {
            adjustmentHeight -= 30
        }
        scrolView.contentInset.bottom += adjustmentHeight
        scrolView.scrollIndicatorInsets.bottom += adjustmentHeight
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InsertSeekerVC.dismissKeyboard))
        NotificationCenter.default.addObserver(self,selector : #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow , object : nil)
        NotificationCenter.default.addObserver(self,selector : #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide , object : nil)
        
        view.addGestureRecognizer(tap)
        submitButton.layer.cornerRadius = 20
        
        
    }
    
    @objc func dismissKeyboard ( ){
        self.view.endEditing(true)
    }

        // Do any additional setup after loading the view.
}

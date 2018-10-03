//
//  AdminContactInfoViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 7/2/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import HKProgressHUD


class AdminContactInfoViewController: UIViewController {
    
    @IBOutlet weak var scrollView:UIScrollView!
    
    
    @IBOutlet weak var addressField: UITextField!       //  Place
    @IBOutlet weak var mobileField:  UITextField!       //  dtell
    @IBOutlet weak var faxField:     UITextField!       //  ftell
    @IBOutlet weak var phoneFiled:   UITextField!       //  stell
    @IBOutlet weak var emailField:   UITextField!       //  mail
    @IBOutlet weak var websiteField: UITextField!       //  web
    @IBOutlet weak var submitButton: UIButton!
    
    
    
    
    var usernameText :String = ""
    var passText: String = ""
    let defaults = UserDefaults.standard
    var storeID : Int = 0
    var hud = HKProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
                 UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)
        submitButton.layer.cornerRadius = 10
        self.title = "تکمیل اطلاعات"
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        usernameText = defaults.string(forKey: "username")!
        passText = defaults.string(forKey: "password")!
        
        
        NotificationCenter.default.addObserver(self,selector : #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow , object : nil)
        NotificationCenter.default.addObserver(self,selector : #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide , object : nil)
        
        view.addGestureRecognizer(tap)
        //hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
        hud.label?.text = NSLocalizedString("در حال بارگذاری...", comment: "لطفا صبر کنید!")
        alamoDoLogin(username: usernameText, password: passText)
        
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        view.addGestureRecognizer(tap)
        
        
        
    }
    
    @IBAction func submitChange(_ sender: Any) {
        alamoPostJSON()
        
    }
    
    func alamoDoLogin(username:String, password:String){
        let infoEndPoint: String = "http://shahrvandsho.ir/api/login"
        let loginDetail: [String:Any] = ["email":username,"pass":password]
        Alamofire.request(infoEndPoint, method: .post , parameters: loginDetail, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard response.result.error == nil else {
                    //got an error in getting the data
                    print("error calling PUT ")
                    print(response.result.error!)
                    return
                }
                
                guard let json = response.result.value as? [String:Any] else {
                    print("Didn't get info as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }
                
                guard let resultJSON = json["data"] as? [String : AnyObject] else {
                    let msg = json["error"] as? [String:AnyObject]
                    let alert = UIAlertController(title: "خطا", message: msg?["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.storeID = resultJSON["id"] as! Int
                self.alamoGetStoreData(username: username, password: password)
            
        }
    }
    func alamoGetStoreData(username:String, password:String) {
        let infoEndPoint: String = "http://shahrvandsho.ir/api/store/\(storeID)"
        Alamofire.request(infoEndPoint, method: .get )
            .responseJSON { response in
                guard response.result.error == nil else {
                    //got an error in getting the data
                    print("error calling POST ")
                    print(response.result.error!)
                    return
                }
                
                guard (response.result.value as? [String:Any]) != nil else {
                    print("Didn't get info as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }

                if let dictionary: NSDictionary = response.result.value as? NSDictionary {
                    if let newArr : NSArray = dictionary.object(forKey: "data") as? NSArray {
                        let resultJSON : [String:AnyObject] = newArr[0] as! [String : AnyObject]
                        self.addressField.text = resultJSON["place"] as? String
                
                        self.faxField.text = resultJSON["ftell"] as? String
                        self.emailField.text = resultJSON["mail"] as? String
                        self.phoneFiled.text = resultJSON["stell"] as? String
                        self.mobileField.text = resultJSON["dtell"] as? String
                        self.websiteField.text = resultJSON["web"] as? String
                        _ = HKProgressHUD.hide(addedToView: (self.navigationController!.view)!, animated: true)
                    }
                }
        }
        
    }

    func alamoPostJSON(){
        let infoEndPoint: String = "http://shahrvandsho.ir/api/store/\(storeID)"
        let updateInfo: [String:Any] = ["email":usernameText, "pass":123456 ,"info":"contact", "address":addressField.text!,"tell":mobileField.text!,"phone":phoneFiled.text!,"fax":faxField.text!,"site":websiteField.text!]
        Alamofire.request(infoEndPoint, method: .put, parameters: updateInfo, encoding: JSONEncoding.default)
            
            .responseJSON { response in
                guard response.result.error == nil else {
                    //got an error in getting the data
                    print("error calling PUT ")
                    print(response.result.error!)
                    return
                }
                
                guard (response.result.value as? [String:Any]) != nil else {
                    print("Didn't get info as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }
                
                let alert = UIAlertController(title: "ثبت اطلاعات", message: "اطلاعات با موفقیت ثبت شد!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
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
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        
    }
    

    
    
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        
    }
    
}

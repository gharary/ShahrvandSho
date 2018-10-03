//
//  LoginViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/18/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passText: UITextField!
    
    @IBOutlet weak var loginBtn:UIButton!
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    
    
    let login_url = "http://shahrvandsho.ir/api/login"

    
    var login_session:String = ""
    
    @IBAction func submitBtn(_ sender: Any) {
        if !(usernameText.text?.isEmpty)! && !(passText.text?.isEmpty)! {
     
            //login_now(username:usernameText.text!, password: passText.text!)
            alamoDoLogin(username: usernameText.text!, password: passText.text!)
        } else {
            let alert = UIAlertController(title: "خطا", message: "لطفا اطلاعات خود را وارد کنید:", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    
        
    }
    var showKeyboard : Bool = false
    let defaults = UserDefaults.standard
    var isLoggeinIn:Bool = false
    var tableData:[AnyObject]!
    
    func alamoDoLogin(username:String, password:String) {
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
                
                guard (json["data"] as? [String : AnyObject]) != nil else {
                    let msg = json["error"] as? [String:AnyObject]
                    let alert = UIAlertController(title: "خطا", message: msg?["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let defaults = UserDefaults.standard
                defaults.set(self.usernameText.text, forKey: "username")
                defaults.set(self.passText.text, forKey: "password")
                defaults.set(true, forKey: "isLoggenIn")
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                    
                    self.present(viewController, animated: true, completion: nil)
                    
                })
                
        }
    }

    
    func login_now(username:String, password:String)
    {
        
        let url:URL = URL(string: login_url)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "post"
        var paramString = ""
        
        paramString = paramString + "email=\(usernameText.text!)&pass=\(passText.text!)"        

        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request , completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                let alert = UIAlertController(title: "Http Error", message: "statusCode should be 200, but is \(httpStatus.statusCode)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK!!", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                print("response = \(String(describing: response))")
            } else {
                //print("OK")
                let defaults = UserDefaults.standard
                defaults.set(self.usernameText.text, forKey: "username")
                defaults.set(self.passText.text, forKey: "password")
                defaults.set(true, forKey: "isLoggenIn")

                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                    
                    self.present(viewController, animated: true, completion: nil)
                    
                })
            }

        })
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ورود به اکانت"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
     
        usernameText.layer.cornerRadius = 20
        passText.layer.cornerRadius = 20
        loginBtn.layer.cornerRadius = 20
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRegister" {
            if let nav = segue.destination as? UINavigationController {
                let dc = nav.viewControllers[0] as! RegisterVC1
                dc.segueString = segue.identifier!
            }
        }
    }
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if (showKeyboard != true) {
            showKeyboard = true
            adjustInsetForKeyboardShow(notification: notification)
        }
        
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if (showKeyboard == true) {
            
            
            showKeyboard = false
            adjustInsetForKeyboardShow(notification: notification)
        }
        
    }
    
    func adjustInsetForKeyboardShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height * (showKeyboard ? 1 : -1))
        
        
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        
    }



}

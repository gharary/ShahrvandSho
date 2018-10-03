//
//  ResetPassVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 9/17/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire

class ResetPassVC: UIViewController , UITextFieldDelegate{
    
    
    
    var showKeyboard : Bool = false
    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?

    @IBOutlet weak var sequrityQuestion: UILabel!
    @IBOutlet weak var sequrityAnsTF: UITextField!
    
    @IBOutlet weak var reNewPassTF: UITextField!
    @IBOutlet weak var newPassTF: UITextField!

    
    var sequrityQ:String = "null"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sequrityAnsTF.delegate = self
        self.newPassTF.delegate = self
        self.reNewPassTF.delegate = self
 
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResetPassVC.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        registerForKeyboardNotifications()

    }
    
    func changeLabel(labelToChange: String) {
        sequrityQuestion.text = labelToChange
    }

    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    
    
    let url = URL(string: "http://shahrvandsho.ir/api/change")
    
    
    func changePass(email: String) {
        let infoEndPoint: String = "http://shahrvandsho.ir/api/change"
        let loginDetail: [String:Any] = ["email":email,"ques":sequrityQ,"ans":sequrityAnsTF.text!,"pass":newPassTF.text!]
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
                print("Pass has Changes!")
                
        }

        
    }
    func resetPassword(email: String) {
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let sequrityAns = sequrityAnsTF.text!
        let newPass = newPassTF.text!
        let passRepeat = reNewPassTF.text!
        if newPass == passRepeat {

        let postString = "email=\(email)&ques=\(sequrityQ)&ans=\(sequrityAns)&pass=\(newPass)"
        
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
        } else {
            
            let alert = UIAlertController(title: "خطا", message: "رمز جدید با هم یکسان نیست", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "سعی مجدد!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        print("pass reset!")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
        
    }


    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        //self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    



}
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}

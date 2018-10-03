//
//  RegisterVC3.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 10/11/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField
import Alamofire
import HKProgressHUD

class RegisterVC3: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var datePicker:UIPickerView!
    @IBOutlet weak var sequrityAnsTF:UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let url = URL(string: "http://shahrvandsho.ir/api/store/")
    
    var pickerDataSource = ["نام حیوان خانگی تان","اسم مستعار زمان کودکی تان","اولین مدرسه تحصیلی تان","نام اولین معلمان "]
    
    var showKeyboard : Bool = false
    var seqQ:String = ""
    
    var usernameStr: String? = ""
    var passwordStr:String? = ""
    var emailStr:String? = ""
    var storeTitleStr:String? = ""
    var managerNameStr:String? = ""
    var mobileStr:String? = ""
    var addressStr:String? = ""
    
    var hud = HKProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.delegate = self
        self.datePicker.dataSource = self
        sequrityAnsTF.becomeFirstResponder()
        submitButton.alpha = 0.5
        submitButton.isEnabled = false
        //setupPickerBorder()
        setupTextField()
        
    }
    
    func setupTextField() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        sequrityAnsTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        submitButton.layer.cornerRadius = 10
        //submitButton.layer.borderWidth = 2
        
    }
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    
    
    @objc func textFieldDidChange(textField: UITextField) {
        if textField == sequrityAnsTF {
            if !(textField.text?.isEmpty)! {
                submitButton.alpha = 1.0
                submitButton.isEnabled = true
                
            }
        }
    }
    
    @IBAction func backToHome(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "UnwindToHomeVC", sender: self)
        /*let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyBoard.instantiateViewController(withIdentifier: "FirstView")
        self.present(newVC, animated: true, completion: nil)*/
        
        
    }
    @IBAction func backBtn(_ sender: Any) {
        //performSegueToReturnBack()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        view.endEditing(true)
        
        
        guard
            let id = usernameStr, !id.isEmpty,
            let email = emailStr, !email.isEmpty,
            let pass = passwordStr, !pass.isEmpty,
            let title = storeTitleStr, !title.isEmpty,
            let tell = mobileStr, !tell.isEmpty,
            let ans = sequrityAnsTF.text, !ans.isEmpty,
            let address = addressStr, !address.isEmpty,
            let manager = managerNameStr, !manager.isEmpty
            
            else
        {
            let alert = UIAlertController(title: "اخطار", message: "همه گزینه ها باید پر شود!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        hud = HKProgressHUD.show(addedToView: (self.view)!, animated: true)
        hud.label?.text = NSLocalizedString("در حال ثبت اطلاعات", comment: "لطفا کبی صبر کنید.")
        DispatchQueue.main.async {

            self.register(nameField: self.seqQ, emailField: id, passField: pass, titleField: title, tellField: tell, addressField: address, ansField: ans, adminField: manager,mailField:email)
        self.submitButton.alpha = 0.5
        }
    }
    
    func setupPickerBorder() {
        datePicker.layer.borderColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1).cgColor
        datePicker.layer.borderWidth = 2.0
        datePicker.layer.cornerRadius = 20
        
        sequrityAnsTF.layer.cornerRadius  = 20
        sequrityAnsTF.layer.borderWidth = 2.0
        sequrityAnsTF.layer.borderColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1).cgColor
    }
    
    func register(nameField: String, emailField:String, passField:String, titleField:String, tellField:String, addressField:String, ansField:String, adminField:String,mailField:String) {
        let infoEndPoint: String = "http://shahrvandsho.ir/api/store"
        let loginDetail: [String:Any] = ["name":nameField,"email":emailField,"admin":adminField,"pass":passField,"title":titleField,"tell":tellField,"ans":ansField,"address":addressField,"mail":mailField]
        //print("Register Func !!")
        Alamofire.request(infoEndPoint, method: .post , parameters: loginDetail, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard response.result.error == nil else {
                    //got an error in getting the data
                    print("error calling PUT ")
                    print(response.result.error!)
                     _ = HKProgressHUD.hide(addedToView: (self.view), animated: true)
                    return
                }
                
                guard let json = response.result.value as? [String:Any] else {
                    print("Didn't get info as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                     _ = HKProgressHUD.hide(addedToView: (self.view), animated: true)
                    return
                }
                
                guard (json["data"] as? [String : AnyObject]) != nil else {
                     _ = HKProgressHUD.hide(addedToView: (self.view), animated: true)
                    let msg = json["error"] as? [String:AnyObject]
                    let alert = UIAlertController(title: "خطا", message: msg?["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                print(json["data"]!)
                DispatchQueue.main.async {
                    _ = HKProgressHUD.hide(addedToView: (self.view), animated: true)
                    let alert  = UIAlertController(title: " !ثبت اطلاعات با موفقیت انجام شد", message: "بعد از تایید شما میتوانید اطلاعات و عکس فروشگاه خود را اضافه کنید.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler:{ action in
                        self.backToHome(self.view)
                        
                    }))
                    
                    self.present(alert, animated: true, completion:nil)
                    
            }
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "IRANSANSMOBILE-Light", size: 16)
        
        // where data is an Array of String
        label.text = pickerDataSource[row]
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seqQ = pickerDataSource[row] as String
    }
 
    
    
    
}





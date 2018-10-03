//
//  RegisterViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/20/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class RegisterVC1: UIViewController, UITextFieldDelegate {
 
    @IBOutlet weak var currentNavBar: UINavigationBar!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var passwordTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var rePasswordTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var usernameTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var nextVCBtn: UIBarButtonItem!
    
    
    @IBAction func returnBtn(_ sender: Any) {
       //print("Return BTN!")
        self.dismiss(animated: true, completion: nil)
    }
    var textFields: [SkyFloatingLabelTextField] = []
    
    let lightGreyColor: UIColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor: UIColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor:UIColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    var segueString: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        usernameTF.becomeFirstResponder()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        //nextVCBtn.isEnabled = false
        textFieldDidChange(textField: usernameTF)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields = [emailTextField, passwordTF, rePasswordTF, usernameTF]
        setupFields()
        //currentNavBar.topItem?.title = "ثبت نام"
        navigationController?.title = "ثبت نام"
        usernameTF.becomeFirstResponder()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        emailTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        rePasswordTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        usernameTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        nextVCBtn.isEnabled = false
    
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if textField == rePasswordTF {
            let result = validateRePass(textField: rePasswordTF)
            if !result {
                nextVCBtn.isEnabled = false
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                return
                
            }
        }
        if (emailTextField.text == "" || passwordTF.text == "" || rePasswordTF.text == "" || usernameTF.text == "") {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            nextVCBtn.isEnabled = false
            
        } else {
            
            if ((emailTextField.errorMessage == "" || emailTextField.errorMessage == nil) && (usernameTF.errorMessage == "" || usernameTF.errorMessage == nil) && (passwordTF.errorMessage == "" || passwordTF.errorMessage == nil) && (rePasswordTF.errorMessage == "" || rePasswordTF.errorMessage == nil)) {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                nextVCBtn.isEnabled = true
                
            } else {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                nextVCBtn.isEnabled = false
                
            }
        }
        
    }
    
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    
    
   // @IBOutlet weak var nextVCBtn: UIBarButtonItem!

    @IBAction func showNextVC(_ sender: UIBarButtonItem) {
        //print("ShowBtn")
        performSegue(withIdentifier: "segueToRegisterVC2", sender: self)
    }
    
    
    
    func setupFields() {
        for textField in textFields {
            applySkyscannerThemeWithIcon(textField: textField as! SkyFloatingLabelTextFieldWithIcon)
            textField.delegate = self
            textField.isLTRLanguage = false
        }
        usernameTF.placeholder = "نام کاربری (انگلیسی)"
        usernameTF.title = "نام کاربری"
        usernameTF.iconText = "\u{f007}"
        
        emailTextField.placeholder = "آدرس ایمیل"
        emailTextField.title = "ایمیل"
        emailTextField.iconText = "\u{f003}"
        
        passwordTF.placeholder = "رمز عبور (حداقل ۶ حرف)"
        passwordTF.title = "رمز عبور"
        passwordTF.iconText = "\u{f084}"
        
        rePasswordTF.placeholder = "تکرار رمز عبور"
        rePasswordTF.title = "تکرار رمز عبور"
        rePasswordTF.iconText = "\u{f084}"
        
        
    }
    func applySkyscannerThemeWithIcon(textField: SkyFloatingLabelTextFieldWithIcon) {
        self.applySkyscannerTheme(textField: textField)
        
        textField.iconColor = lightGreyColor
        textField.selectedIconColor = overcastBlueColor
        textField.iconFont = UIFont(name: "FontAwesome", size: 15)
        textField.titleLabel.font = UIFont(name: "IRANSANSMOBILE", size: 15)
        textField.placeholderFont = UIFont(name: "IRANSANSMOBILE-Light", size: 15)
        
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        
        textField.tintColor = overcastBlueColor
        
        textField.textColor = darkGreyColor
        textField.lineColor = lightGreyColor
        
        textField.selectedTitleColor = overcastBlueColor
        textField.selectedLineColor = overcastBlueColor
        
        // Set custom fonts for the title, placeholder and textfield labels
        textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 18)
        textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
    }
    
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    if textField == emailTextField {
        validateEmailField()
    } else if textField == passwordTF {
        validatePassword(textField: passwordTF)
    } else if let textField = rePasswordTF {
        if textField.text == "" {
            textField.errorMessage = ""
        }
    }
    return true
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == rePasswordTF {
            _ = validateRePass(textField: rePasswordTF)
        }
        return true
    }
    func validatePassword(textField: UITextField) {
        if let text = textField.text {
            if let floatingLabelTextField = passwordTF {
                floatingLabelTextField.textAlignment = .center
                if (text.characters.count < 5 ) {
                    floatingLabelTextField.errorMessage = "رمزعبور حداقل ۶ حرف"
                } else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }
    
    func validateRePass(textField: UITextField) -> Bool {
        if let text = textField.text {
            if let floatingLabelTextField = rePasswordTF {
                floatingLabelTextField.textAlignment = .center
                if text != passwordTF.text {
                    floatingLabelTextField.errorMessage = "رمزهای عبور یکسان نیست"
                    return false
                } else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                    return true
                    
                }
            }
        }
        return false
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nextTag = textField.tag + 1
        if let nextResponsder = textField.superview?.viewWithTag(nextTag) as UIResponder! {
            nextResponsder.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
    }
    
    func validateEmailField() {
        validateEmailTextFieldWithText(email: emailTextField.text)
    }
    
    func validateEmailTextFieldWithText(email: String?) {
        guard let email = email else {
            emailTextField.errorMessage = nil
            return
        }
        
        if email.characters.isEmpty {
            emailTextField.errorMessage = nil
        } else if !validateEmail(candidate: email) {
            emailTextField.errorMessage = NSLocalizedString(
                "ایمیل نامعتبر",
                tableName: "SkyFloatingLabelTextField",
                comment: " "
            )
        } else {
            emailTextField.errorMessage = nil
        }
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRegisterVC2" {
            if let vc = segue.destination as? RegisterVC2
            {
                vc.usernameStr = self.usernameTF.text!
                vc.passwordStr = self.passwordTF.text!
                vc.emailStr = self.emailTextField.text!
            }
        }
    }
}

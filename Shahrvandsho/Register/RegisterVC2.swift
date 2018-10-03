//
//  SignUpVC1.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 9/27/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class RegisterVC2: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var storeTitleTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var managerNameTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var mobileNumberTF: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var addressTF: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet weak var returnToBack: UIBarButtonItem!
    
    var textFields:[SkyFloatingLabelTextField] = []
    
    let lightGreyColor: UIColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor: UIColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor:UIColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    var usernameStr: String = ""
    var passwordStr:String = ""
    var emailStr:String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        storeTitleTF.becomeFirstResponder()
        //self.navigationItem.leftBarButtonItem?.isEnabled = false
        returnToBack.isEnabled = false
        
        textFieldDidChange(textField: storeTitleTF)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [storeTitleTF,managerNameTF,mobileNumberTF,addressTF]
        //self.navigationItem.leftBarButtonItem?.isEnabled  = false
        
        setupFields()
        setupTextField()
        storeTitleTF.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
        
        //"phone f10a, f10b, f098, f095"
        //f183, f2bd, f2be, f2c0 modir,
        //f277,f278,f279 address
        //f290, f291 onvane vahed
    }
    
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    
    func setupTextField() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        storeTitleTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        managerNameTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        mobileNumberTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        addressTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        returnToBack.isEnabled = false
        
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if (storeTitleTF.text == "" || managerNameTF.text == "" || mobileNumberTF.text == "" || addressTF.text == "") {
            //self.navigationItem.leftBarButtonItem?.isEnabled = false
            returnToBack.isEnabled = false
            
        } else {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            returnToBack.isEnabled = true
            
            
        }
    }
    
    func setupFields() {
        for textField in textFields {
            applySkyscannerThemeWithIcon(textField: textField as! SkyFloatingLabelTextFieldWithIcon)
            textField.delegate = self
            textField.isLTRLanguage = false
            
        }
        storeTitleTF.iconText = "\u{f290}"
        managerNameTF.iconText = "\u{f183}"
        mobileNumberTF.iconText = "\u{f095}"
        addressTF.iconText = "\u{f278}"
        print(addressTF.iconWidth)
        addressTF.iconWidth = 30
        storeTitleTF.iconWidth = 25
        managerNameTF.iconWidth = 30
        mobileNumberTF.iconWidth = 30
        
        
        
    }
    func applySkyscannerThemeWithIcon(textField: SkyFloatingLabelTextFieldWithIcon) {
        self.applySkyscannerTheme(textField: textField)
        
        textField.iconColor = lightGreyColor
        textField.selectedIconColor = overcastBlueColor
        textField.iconFont = UIFont(name: "FontAwesome", size: 17)
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
        textField.titleLabel.font = UIFont(name: "IRANSANSMOBILE-Regular", size: 12)
        textField.placeholderFont = UIFont(name: "IRANSANSMOBILE-Light", size: 18)
        textField.textAlignment = .center
        textField.font = UIFont(name: "IRANSANSMOBILE-Regular", size: 18)
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //performSegueToReturnBack()
        //self.navigationController?.popToRootViewController(animated: true)
        //self.navigationController?.popToViewController(RegisterVC1, animated: true)
    }
    
    @IBAction func showNextVC(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "segueToRegisterVC3", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RegisterVC3
        {
            vc.usernameStr = self.usernameStr
            vc.passwordStr = self.passwordStr
            vc.emailStr = self.emailStr
            vc.storeTitleStr = self.storeTitleTF.text!
            vc.managerNameStr = self.managerNameTF.text!
            vc.mobileStr = self.mobileNumberTF.text!
            vc.addressStr = self.addressTF.text!
            
            
        }
    }

}

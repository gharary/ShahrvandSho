//
//  RegisterTableViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire

class RegisterTableViewController: UITableViewController , UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var tblDemo: UITableView!

    @IBAction func backBtn(_ sender: Any) {
        print("back key pressed!")
        
        if segueString == "segueToRegister" {
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        } else if segueString == "" {
            performSegue(withIdentifier: "unwindSegueToFirstVC", sender: self)
        }
    }
    
    var segueString: String = ""
    
    @IBOutlet weak var sequrityTick:UIImageView!
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTick: UIImageView!
    
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var passTick: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleTick: UIImageView!
    
    @IBOutlet weak var phoneTextField:UITextField!
    @IBOutlet weak var phoneTick:UIImageView!
    
    @IBOutlet weak var idTextField:UITextField!
    @IBOutlet weak var idTick:UIImageView!
    
    @IBOutlet weak var sequrityAnsText:UITextField!
    @IBOutlet weak var sequrityAnsTick:UIImageView!
    
    @IBOutlet weak var addressTextField:UITextField!
    @IBOutlet weak var addressTick:UIImageView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    let url = URL(string: "http://shahrvandsho.ir/api/store/")
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerDataSource = ["نام حیوان خانگی تان","اسم مستعار زمان کودکی تان","اولین مدرسه تحصیلی تان","نام اولین معلمان "]
    
    
    var showKeyboard : Bool = false
    var seqQ:String = ""
    
    func register(name: String, email:String, pass:String, title:String, tell:String, address:String, ans:String, mail:String) {
        let infoEndPoint: String = "http://shahrvandsho.ir/api/store"
        let loginDetail: [String:Any] = ["name":name,"email":email,"pass":pass,"title":title,"tell":tell,"ans":ans,"address":address]
        
        //let postString = "name=\(seqQ)&email=\(id)&pass=\(pass)&title=\(title)&tell=\(tell)&address=\(address)&ans=\(ans)&mail=\(email)"

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
                
                print(json["data"]!)
                let alert  = UIAlertController(title: " !ثبت اطلاعات با موفقیت انجام شد!", message: "بعد از تایید شما میتوانید در عکس فروشگاه خود را اضافه کنید.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
        }
    }
    
    
    @IBAction func submitBtn(_ sender: Any) {
        view.endEditing(true)
        
        
        guard
            let email = emailTextField.text, !email.isEmpty,
            let pass = passTextField.text, !pass.isEmpty,
            let title = titleTextField.text, !title.isEmpty,
            let tell = phoneTextField.text, !tell.isEmpty,
            let id = idTextField.text, !id.isEmpty,
            let ans = sequrityAnsText.text, !ans.isEmpty,
            let address = addressTextField.text, !address.isEmpty
        
            else
        {
            let alert = UIAlertController(title: "اخطار", message: "همه گزینه ها باید پر شود!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
    
        register(name: seqQ, email: id, pass: pass, title: title, tell: tell, address: address, ans: ans, mail: email)
        submitButton.alpha = 0.5
    }
    
    var currentCell :NSIndexPath? = nil
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
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
        return 45.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seqQ = pickerDataSource[row] as String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        print("segueString is: \(segueString)")
        barButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE-Medium", size: 12)!], for: UIControlState.normal)
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterTableViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        idTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        sequrityAnsText.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
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
        var adjustmentHeight = (keyboardFrame.height * (showKeyboard ? 1 : -1))
        
        if (showKeyboard) {
            adjustmentHeight += 30
        } else {
            adjustmentHeight -= 30
            
        }
        //tblDemo.contentInset.bottom += adjustmentHeight
        tblDemo.scrollIndicatorInsets.bottom += adjustmentHeight

        
    }
    
     @objc func textFieldDidChange(textField: UITextField){

        //var indexPath = IndexPath(row: 0, section: 0)
        switch textField {
        case emailTextField:
            //indexPath = IndexPath(row: 1, section: 0)
            switch textField.text {
            case let input? where !input.isEmpty && (String(describing: textField).lowercased().range(of:"@") != nil):
                //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                emailTick.image = UIImage(named: "tick")
            case let input? where input.isEmpty :
                emailTick.image = nil
                //tableView.cellForRow(at: indexPath)?.accessoryType = .none
            default:
                emailTick.image = nil
                //tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        case passTextField:
            switch textField.text {
            case let input? where !input.isEmpty && (input.characters.count > 7):
                passTick.image = UIImage(named: "tick")
            case let input? where input.isEmpty :
                passTick.image = nil
            default:
                passTick.image = nil
            }
        case titleTextField:
            switch textField.text {
            case let input? where !input.isEmpty :
                titleTick.image = UIImage(named: "tick")
            case let input? where input.isEmpty :
                titleTick.image = nil
            default:
                titleTick.image = nil
            }
        case idTextField:
            switch textField.text {
            case let input? where !input.isEmpty && (input.characters.count > 6):
                idTick.image = UIImage(named: "tick")
            case let input? where input.isEmpty :
                idTick.image = nil
            default:
                idTick.image = nil
            }
        case phoneTextField:
            switch textField.text {
            case let input? where !input.isEmpty && (input.characters.count > 10):
                phoneTick.image = UIImage(named: "tick")
            case let input? where input.isEmpty :
                phoneTick.image = nil
            default:
                phoneTick.image = nil
            }
        case addressTextField:
            switch textField.text {
            case let input? where !input.isEmpty :
                addressTick.image = UIImage(named: "tick")
            case let input? where input.isEmpty :
                addressTick.image = nil
            default:
                addressTick.image = nil
            }
        case sequrityAnsText:
            switch textField.text {
            case let input? where !input.isEmpty && (input.characters.count > 2):
                sequrityAnsTick.image = UIImage(named: "tick")
                sequrityTick.image = UIImage(named: "tick")
                
            case let input? where input.isEmpty :
                sequrityAnsTick.image = nil
            default:
                sequrityAnsTick.image = nil
            }
        default: break
            
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
    }


}


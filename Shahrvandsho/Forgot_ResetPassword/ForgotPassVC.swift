//
//  ForgotPassVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 9/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire


class ForgotPassVC: UIViewController {


    @IBOutlet weak var submitBtn:UIButton!
    @IBOutlet weak var userNameTextField:UITextField!
    @IBOutlet weak var resetPassContainer: UIView!
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var sequrityQ:String = ""
    let server_url = "http://shahrvandsho.ir/api/reset"
    
    
    @IBAction func submitButton(_ sender: Any) {
        dismissKeyboard()
        if resetPassContainer.isHidden == true {
            self.getSequrityQuestion(username: self.userNameTextField.text!)
            
        } else {
            let CVC = childViewControllers.last as! ResetPassVC
            //CVC.resetPassword(email: userNameTextField.text!)
            CVC.changePass(email: userNameTextField.text!)
            
        }
        
        
    }
    
    func getSequrityQuestion(username:String) {

        let infoEndPoint: String = "http://shahrvandsho.ir/api/reset"
        let loginDetail: [String:Any] = ["email":username]
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
                let tempdata = json["data"] as? [String: AnyObject]
                
                self.sequrityQ = (tempdata?["question"] as? String)!
                self.showContainer()
 
        }

    }
    
    func showContainer() {
        let CVC = childViewControllers.last as! ResetPassVC
        CVC.changeLabel(labelToChange: self.sequrityQ)
        self.resetPassContainer.isHidden = false
        self.submitBtn.setTitle("تغییر", for: .normal)
    }
    
   /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContainer" {
            let childVC = segue.destination as! ResetPassVC
            let desController = segue.destination as! ResetPassVC
            desController.sequrityQ = sequrityQ
        }
    }
*/
    
    override func viewWillAppear(_ animated: Bool) {
        resetPassContainer.isHidden = true
        
    }
    
    fileprivate var resetPassViewController: ResetPassVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 20
        
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForgotPassVC.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        setAddTargetIsNotEmptyTF()
        
        guard let resetController = childViewControllers.first as? ResetPassVC else {
            fatalError("check storyboard for missing ResetVC Container")
        }
        
        resetPassViewController = resetController
        //resetController.delegate = self
        
        
        
        
        
    }
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    
    func setAddTargetIsNotEmptyTF() {
        submitBtn.isEnabled = false
        submitBtn.alpha = 0.5
        
        userNameTextField.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        
        
    }
    
    @objc func textFieldIsNotEmpty(sender: UITextField) {
        guard
            let username = userNameTextField.text, !username.isEmpty
        
            else {
                submitBtn.alpha = 0.5
                submitBtn.isEnabled = false
                return
        }
        submitBtn.alpha = 1.0
        submitBtn.isEnabled = true
        
    }


}

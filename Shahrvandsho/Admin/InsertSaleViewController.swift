//
//  InsertSaleViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 7/2/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import HKProgressHUD



class InsertSaleViewController: UIViewController, UIImagePickerControllerDelegate,URLSessionDelegate,URLSessionTaskDelegate,URLSessionDataDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var goodImg1:UIImageView!
    @IBOutlet weak var img1Progress:UIProgressView!
    
    @IBOutlet weak var goodImg2: UIImageView!
    
    @IBOutlet weak var goodImg3: UIImageView!
    
    @IBOutlet weak var goodNameTxtFld:UITextField!
    
    @IBOutlet weak var beginDateTxtFld: UITextField!
    @IBOutlet weak var endDateTxtFld: UITextField!
    
    @IBOutlet weak var offPercentTxtFld: UITextField!
    
    @IBOutlet weak var priceTxtFld: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var picLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var usernameText : String = ""
    var passText : String = "123456"
    let defaults = UserDefaults.standard
    var storeID : Int = 0
    
    
    var responseData = NSMutableData()
    
    var keyStatus = false
    
    

    @IBAction func submitAddSaleBtn(_ sender: Any) {
 
        dismissKeyboard()
        submitJSON()
    }
    
    @IBAction func returnBtn(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var newMedia: Bool?
    var showKeyboard : Bool = false
    
    @IBAction func selectCameraOrPhoto(sender: AnyObject) {
        
        let alert = UIAlertController(title: "اضافه کردن عکس از:", message: "", preferredStyle: .actionSheet)
    
        
        alert.addAction(UIAlertAction(title: "گالری", style: .default, handler: { (action) in
            //execute some code
            self.useCameraRoll()
            
        }))
        
        alert.addAction(UIAlertAction(title: "دوربین", style: .default, handler: { (action) in
            self.useCamera()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    

    func useCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            newMedia = true
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
     func useCameraRoll() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            newMedia = false
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        goodImg1.image = image
        
        if (newMedia == true) {
          
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    @objc func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image on disk",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
        }
    }
    

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        goodImg1.image = image
        self.dismiss(animated: true, completion: nil);
    }
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InsertSaleViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        self.title = "درج تخفیفی"
        setupAddTargetIsNotEmptyTextFields()
        
        //img1Progress.progress = 0
        
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        picLabel.layer.cornerRadius = 10
        picLabel.layer.borderWidth = 3
        picLabel.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        picLabel.layer.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor

        
        infoLabel.layer.cornerRadius = 10
        infoLabel.layer.borderWidth = 3
        infoLabel.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        
        infoLabel.layer.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor

        usernameText = defaults.string(forKey: "username")!
        passText = defaults.string(forKey: "password")!
        
        alamoDoLogin(username: usernameText, password: passText)
        
        
    }
    
    func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didSendBodyData bytesSent: Int64,
                             totalBytesSent: Int64,
                             totalBytesExpectedToSend: Int64){
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        //let progressPercent = Int(uploadProgress*100)
        //print(progressPercent)
        //img1Progress.progress = uploadProgress
        //let hud = HKProgressHUD.show(addedToView: self.view, animated: true)
        let hud = HKProgressHUD.hudForView(self.view)
        hud?.mode = .determinate
        hud?.progress = uploadProgress
        
    }
    
    
    func submitJSON() {
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        
        
        let newBegin = beginDateTxtFld.text?.replacingOccurrences(of: "/", with: "-")
        let newEnd = endDateTxtFld.text?.replacingOccurrences(of: "/", with: "-")
        
        let img = goodImg1.image?.resizedTo100K()
        let image : Data = UIImagePNGRepresentation(img!)!
        
        let imageStr = image.base64EncodedString(options: .endLineWithCarriageReturn)
        
        
        let params: [String:String] = ["email":usernameText, "pass":passText ,"adver_id":"\(storeID)","product":goodNameTxtFld.text!,"start":newBegin!,"end":newEnd!,"percent":offPercentTxtFld.text!,"price":priceTxtFld.text!,"photo":imageStr]
        
        
        var r  = URLRequest(url: URL(string: "http://shahrvandsho.ir/api/off")!)
        r.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        r.httpBody = createBody2(parameters: params,
                                boundary: boundary)
        
        //testing new task for progress
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: r) {
            data, response, error in

            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                //print("error=\(String(describing: error))")
                let alert = UIAlertController(title: "خطا", message: "خطا زیر رخ داد: \(String(describing: error))", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in}))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(String(describing: response))")
                let alert = UIAlertController(title: "خطا", message: "خطا زیر رخ داد: \(String(describing: response))", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in}))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            //let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(String(describing: responseString))")
            //print("Response utF = \(String(describing: responseString?.utf8))")
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                let tableData = dic.value(forKey : "data") as? [String:AnyObject]
                if let id = tableData?["id"] {
                    let alert = UIAlertController(title: "", message: " اطلاعات شما با آیدی \(id) ثبت شد!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in}))
                    self.present(alert, animated: true, completion: nil)
                }
            } catch {
                
            }
            
        }
        task.resume()
        
        
    }
        //it's working but without progress
        /*
        let task = URLSession.shared.dataTask(with: r) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(String(describing: responseString))")
            print("Response utF = \(String(describing: responseString?.utf8))")
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: [])
                print("dic is: \(dic)")
            } catch {
                
            }
        }
        task.resume()
         }
        */
        
    func createBody2(parameters: [String: String],
                    boundary: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        return body as Data
    }
    
    func alamoDoLogin(username:String, password:String){
        let infoEndPoint: String = "http://shahrvandsho.ir/api/login"
        let loginDetail: [String:Any] = ["email":username,"pass":password]
        Alamofire.request(infoEndPoint, method: .post , parameters: loginDetail, encoding: JSONEncoding.default).responseJSON { response in
                guard response.result.error == nil else {
                    //got an error in getting the data
                    print("error loging into Server! ")
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
        }
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
        
        
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        
    }
    
    
    func setupAddTargetIsNotEmptyTextFields () {
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        //img1Progress.alpha = 0
        
        //submitButton.isUserInteractionEnabled = false
        
        goodNameTxtFld.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        beginDateTxtFld.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        endDateTxtFld.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        offPercentTxtFld.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        priceTxtFld.addTarget(self, action: #selector(textFieldIsNotEmpty), for: .editingChanged)
        
    }
    
    @objc func textFieldIsNotEmpty(sender: UITextField) {
    
        guard
            let name = goodNameTxtFld.text, !name.isEmpty,
            let begin = beginDateTxtFld.text, !begin.isEmpty,
            let end = endDateTxtFld.text, !end.isEmpty,
            let price = priceTxtFld.text, !price.isEmpty
        else
        {
            submitButton.alpha = 0.5
            self.submitButton.isEnabled = false
            return
        }
        submitButton.alpha = 1.0
        submitButton.isEnabled = true
        //submitButton.isUserInteractionEnabled = true
        //img1Progress.alpha = 1.0

        
    }
    
    @IBAction func textFieldEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.calendar = NSCalendar(identifier: NSCalendar.Identifier.persian) as Calendar!
        datePickerView.locale = NSLocale(localeIdentifier: "fa_IR") as Locale!
        
        sender.inputView = datePickerView
        if sender == beginDateTxtFld {
            datePickerView.addTarget(self, action: #selector(self.beginDatePickerValueChanged), for: UIControlEvents.valueChanged)
        }
        if sender == endDateTxtFld {
            datePickerView.addTarget(self, action: #selector(self.endDatePickerValueChanged), for: UIControlEvents.valueChanged)
        }

    }
    
    @IBAction func percentEndEditing(_ sender: Any) {
        guard let result = Int((offPercentTxtFld.text)!) else
        {
            return
        }
        if result > 100 {
            offPercentTxtFld.text = ""
            let alert = UIAlertController(title: "خطا در درصد", message: "درصد باید عددی بین ۱ تا ۱۰۰ باشد!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "باشه!", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in}))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func textFieldEndEditing(_ sender: Any) {
        
        let dateFormatter = DateFormatter()
            
            
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            //dateFormatter.dateStyle = DateFormatter.Style.short
            //dateFormatter.timeStyle = DateFormatter.Style.none
            
            let text = beginDateTxtFld.text!
            
            let dateBegin = dateFormatter.date(from: text)
            
            let dateEnd = dateFormatter.date(from: endDateTxtFld.text!)
            
            if let result = dateEnd?.timeIntervalSince(dateBegin!) {
                if Int(result) < 0 {
                    let alert = UIAlertController(title: "خطا در تاریخ", message: "تاریخ پایان نباید کمتر از تاریخ شروع باشد!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in}))
                    
                    self.present(alert, animated: true, completion: nil)
                    endDateTxtFld.text = ""
                    
                }
            }
        

    }

    
    @objc func beginDatePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.calendar = Calendar(identifier: .persian)
        
        let date = dateFormatter.string(from: sender.date)
        
        
        
        //dateFormatter.dateStyle = DateFormatter.Style.MediumStyle
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        
        //dateFormatter.timeStyle = DateFormatter.Style.NoStyle
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        beginDateTxtFld.text = date
    }
    @objc func endDatePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.calendar = Calendar(identifier: .persian)
        
        let date = dateFormatter.string(from: sender.date)
        
        
        //dateFormatter.dateStyle = DateFormatter.Style.MediumStyle
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        
        //dateFormatter.timeStyle = DateFormatter.Style.NoStyle
        dateFormatter.timeStyle = DateFormatter.Style.none
        endDateTxtFld.text = date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
//extension UIViewController {
//    
//    func alert(message: String, title: String = "") {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(OKAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
//    
//}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}



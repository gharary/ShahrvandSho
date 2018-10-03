//
//  InfoPicViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 7/10/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import HKProgressHUD
import MBProgressHUD


class InfoPicViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,URLSessionDelegate,URLSessionTaskDelegate,URLSessionDataDelegate {

    @IBOutlet weak var goodImg1:UIImageView!
    @IBOutlet weak var goodImg2: UIImageView!
    @IBOutlet weak var goodImg3: UIImageView!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var picLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var newMedia: Bool?
    var imgNo:Int = 0
    
    @IBAction func image1Btn(_ sender: Any) {
        imgNo = 1
        alertForCamera()
        
    }
    @IBAction func image2Btn(_ sender: Any) {
        imgNo = 2
        alertForCamera()
    }
    @IBAction func image3Btn(_ sender: Any) {
        imgNo = 3
     alertForCamera()
    }
    
    func alertForCamera() {
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
        switch imgNo {
        case 1:
            goodImg1.image = image
        case 2:
            goodImg2.image = image
        case 3:
            goodImg3.image = image
        default:
            goodImg1.image = image
        }
        //goodImg1.image = image
        
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
    
    var usernameText : String = ""
    var passText : String = ""
    let defaults = UserDefaults.standard
    var storeID : Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        //update the view controller interface using the updated state
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let catTitle = defaults.string(forKey: "CatTitle") {
            categotyTitle = catTitle
            defaults.removeObject(forKey: "CatTitle")
        }
        if let subCatTitle = defaults.string(forKey: "SubCatTitle") {
            categorySubtitle = subCatTitle
            defaults.removeObject(forKey: "SubCatTitle")

        }
        
    }
    
    
    var keyStatus = false
    @objc func keyboardWillShow(notification : NSNotification) {
        if !keyStatus {
            
            keyStatus = true
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
            adjustmentHeight += 50
        }
        else {
            adjustmentHeight -= 50
        }
        //descTextView.contentInset.bottom += adjustmentHeight
        //descTextView.scrollIndicatorInsets.bottom += adjustmentHeight
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        
    }
    
    func getCategoryFromVC(title: String, subtitle:String) {
        categotyTitle = title
        categorySubtitle = subtitle
    }
    var categotyTitle:String = ""
    var categorySubtitle:String = ""
    
    
    override func viewDidLoad() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)

        self.title = "توضیحات / عکس"
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        self.alamoDoLogin(username: self.usernameText, password: self.passText)
        
    }
    
    @IBAction func submitChange() {
        dismissKeyboard()
        //submitJSON()
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = .zoom
        hud.label.text = "در حال آماده سازی..."
        hud.hide(animated: true)
        alamoSubmit()
    }
    
    func alamoSubmit() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = .zoom
        hud.contentColor = UIColor.gray
        hud.mode = .annularDeterminate
        let image1 = goodImg1.image?.resizedTo100K()
        hud.progress = 0.2
        let image2 = goodImg2.image?.resizedTo100K()
        hud.progress = 0.4
        let image3 = goodImg3.image?.resizedTo100K()
        hud.progress = 0.6
        let img1: Data? = UIImagePNGRepresentation(image1!)
        let img2: Data? = UIImagePNGRepresentation(image2!)
        let img3: Data? = UIImagePNGRepresentation(image3!)
        
        let imageStr = img1?.base64EncodedString(options: .endLineWithCarriageReturn)
        let imageStr2 = img2?.base64EncodedString(options: .endLineWithCarriageReturn)
        let imageStr3 = img3?.base64EncodedString(options: .endLineWithCarriageReturn)
        
        
        let url:String = "http://shahrvandsho.ir/api/store/\(storeID)"
        let params: [String:Any] = ["email":usernameText,"pass":passText,"info":"details","title":categotyTitle,"subtitle":categorySubtitle,"desc":descTextField.text!,"photo1":imageStr!,"photo2":imageStr2!,"photo3":imageStr3!]
        
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard response.result.error == nil else {
                    //Got an error in putting the data
                    print(response.result.error!)
                    hud.progress = 1.0
                    return
                }
                guard let json = response.result.value as? [String:Any] else {
                    print("Error: \(String(describing: response.result.error))")
                    hud.progress = 1.0
                    hud.hide(animated: true)

                    return
                }
                guard (json["data"] as? [String:AnyObject]) != nil else {
                    let msg = json["error"] as? [String:AnyObject]
                    let alert = UIAlertController(title: "خطا", message: msg?["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                    hud.progress = 1.0
                    hud.hide(animated: true)

                    self.present(alert, animated: true, completion: nil)
                    return
                }
                hud.progress = 1.0
                hud.hide(animated: true)
                let alert  = UIAlertController(title: " !ثبت اطلاعات با موفقیت انجام شد", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))

                
                self.present(alert, animated: true, completion:nil)
                
        }
    }
    
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
    
    
    func submitJSON() {
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        
        
        let image1 = goodImg1.image?.resizedTo100K()
        let image2 = goodImg2.image?.resizedTo100K()
        let image3 = goodImg3.image?.resizedTo100K()
        
        let img1: Data? = UIImagePNGRepresentation(image1!)
        let img2: Data? = UIImagePNGRepresentation(image2!)
        let img3: Data? = UIImagePNGRepresentation(image3!)
        
        let imageStr = img1?.base64EncodedString(options: .endLineWithCarriageReturn)
        let imageStr2 = img2?.base64EncodedString(options: .endLineWithCarriageReturn)
        let imageStr3 = img3?.base64EncodedString(options: .endLineWithCarriageReturn)
        
        
        let params: [String:String] = ["email":usernameText,"pass":passText,"info":"details","title":categotyTitle,"subtitle":categorySubtitle,"desc":descTextField.text!,"photo1":imageStr!,"photo2":imageStr2!,"photo3":imageStr3!]
        
        
        var r  = URLRequest(url: URL(string: "http://shahrvandsho.ir/api/store/\(storeID)")!)
        r.httpMethod = "PUT"
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
    
    
    func alamoDoLogin(username:String, password: String) {
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
                
        }
    
    
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = .zoom
        hud.contentColor = UIColor.gray
        hud.mode = .determinateHorizontalBar
        hud.progress = progress
        if progress >= 1 {
            hud.hide(animated: true)
        }
    }
    
    @IBAction func returnBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //var secondVC = segue.destination.visi
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
        
    }
}
extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    //let myThumb1 = myPicture.resized(withPercentage: 0.1)
    //let myThumb2 = myPicture.resized(toWidth: 72.0)
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resizedTo100K() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else {return nil}
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 512.0
        
        while imageSizeKB > 512.0 {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.8), let imageData = UIImagePNGRepresentation(resizingImage) else {return nil}
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 512.0
            
        }
        return resizingImage
    }
}


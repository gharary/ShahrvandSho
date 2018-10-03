//
//  InsertSelfieVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 11/10/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MBProgressHUD
import Alamofire
import SearchTextField

class InsertSelfieVC: UIViewController , UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var phoneTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var shopNameTextField: SearchTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newPhoto: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    
    var textFields: [SkyFloatingLabelTextField] = []
    var showKeyboard: Bool = false
    var newMedia: Bool?
    var limit = "50"
    var indexOfPage = 1
    var shopNameSelected:Bool = false
    var results = [SearchTextFieldItem]()
    var storeID: Int = 0
    var tableData:[AnyObject]!
    
    
    let lightGreyColor: UIColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    let darkGreyColor: UIColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
    let overcastBlueColor:UIColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields = [usernameTextField,phoneTextField]
        setupSkyFloatingTextField()
        setupSearchTextField()
        setupTouchKeyboard()
        self.tableData = []

        // Do any additional setup after loading the view.
    }
    
    
    @objc func searchShop() {
        
    }
    
    func setupSearchTextField(){
        shopNameTextField.placeholder = "جستجوی نام فروشگاه"
        shopNameTextField.theme.font = UIFont(name: "IRANSANSMOBILE", size: 15)! //UIFont(name: "FontAwesome", size: 15)!
        //shopNameTextField.theme = .darkTheme()
        shopNameTextField.theme.bgColor = .white
        shopNameTextField.theme.borderColor = .gray
        shopNameTextField.theme.separatorColor = .black
        shopNameTextField.highlightAttributes = [NSAttributedStringKey.backgroundColor: UIColor.yellow, NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 12)!]
        shopNameTextField.textAlignment = .right
        shopNameTextField.forceRightToLeft = true
        
        shopNameTextField.startVisible = true
        shopNameTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            
            self.shopNameTextField.text = item.title
            self.findStoreID(item.title)
            self.shopNameSelected = true
            self.results = []
            
        }
        /**
         * Update data source when the user stops typing.
         * It's useful when you want to retrieve results from a remote server while typing
         * (but only when the user stops doing it)
         **/
        shopNameTextField.userStoppedTypingHandler = {
            self.results = []
            if let criteria = self.shopNameTextField.text {
                if criteria.count > 1 {
                    //Show the loading indicator
                    self.shopNameTextField.showLoadingIndicator()
                    
                    self.searchMoreInBackground(criteria) { result in
                        //Set new items to filter
                        self.shopNameTextField.filterItems(result)
                        
                        //Stop loading indicator
                        self.shopNameTextField.stopLoadingIndicator()
                        
                    }
                }
            }
        }
    }
    
    func findStoreID(_ shopName: String) {
        for item in tableData {
            if item["gjob"] as! String == shopName {
                print("Finded: \(item["gjob"]) : \(item["row"])")
                storeID = item["row"] as! Int
            }
        }
        tableData = []
    }
    func setupSkyFloatingTextField() {
        
        
        for textField in textFields {
            applySkyscannerThemeWithIcon(textField: textField as! SkyFloatingLabelTextFieldWithIcon)
            textField.delegate = self
            textField.isLTRLanguage = false
        }
        usernameTextField.placeholder = "نام و نام خانوادگی"
        usernameTextField.title = "نام و نام خانوادگی"
        usernameTextField.iconText = "\u{f007}"
        
        phoneTextField.placeholder = "تلفن همراه"
        phoneTextField.title = "همراه"
        phoneTextField.iconText = "\u{f098}"
        
        
    }
    
    fileprivate func searchMoreInBackground(_ criteria: String, callback: @escaping ((_ results: [SearchTextFieldItem]) -> Void)) {
        let url:String = "http://shahrvandsho.ir/api/searchStore"
        let params: [String:Any] = ["limit":limit,"page":indexOfPage,"order":"store","term":criteria]
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
            
            guard response.result.error == nil else {
                debugPrint(response.result.error!)
                DispatchQueue.main.async {
                    callback([])
                }
                return}
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print(response.result.value!)
                DispatchQueue.main.async {
                    callback([])
                }
                return }
            
            guard let jsonData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                debugPrint(jsonResult)
                DispatchQueue.main.async {
                    callback([])
                }
                return
            }
            
            
            
            for result in jsonData {
                //results.append(SearchTextFieldItem(title: result["gjob"] as! String, subtitle: criteria.uppercased(), image: UIImage(named: "dailyshop")))
                self.tableData.append(result)
                self.results.append(SearchTextFieldItem(title: result["gjob"] as! String))
            }
            DispatchQueue.main.async {
                callback(self.results)
            }
            
            
            
            
        }
        
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
    @IBAction func newPhotoBtn(_ sender: UIButton) {
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
    
    @IBAction func ruleBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "showRules", sender: nil)
    }
    
    @IBAction func submitPhotoBtn(_ sender: UIButton) {
        dismissKeyboard()
        if !(usernameTextField.text?.isEmpty)! && !(phoneTextField.text?.isEmpty)! && shopNameSelected == true && newPhoto.image != nil {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.animationType = .zoom
            hud.label.text = "در حال آماده سازی"
            hud.hide(animated: true)
        
            alamoSubmit()
        } else {
            let alert = UIAlertController(title: "خطا", message: "همه گزینه ها باید پر شود!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "باشه", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func alamoSubmit() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = .zoom
        hud.contentColor = .gray
        hud.mode = .annularDeterminate
        let image = newPhoto.image?.resizedTo100K()
        hud.progress = 0.5
        
        let img: Data? = UIImagePNGRepresentation(image!)
        let imageStr = img?.base64EncodedString(options: .endLineWithCarriageReturn)
        
        let url:String = "http://shahrvandsho.ir/api/photo"
        let params: [String:String] = ["adver_id":"\(storeID)","name":usernameTextField.text!,"tell":phoneTextField.text!,"store":shopNameTextField.text!,"photo":imageStr!]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                print(response.result.error!)
                hud.progress = 1.0
                
                self.performSegueToReturnBack()
                return
                
            }
            guard let json = response.result.value as? [String:Any] else {
                print("Error \(String(describing: response.result.error))")
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
            alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: { (action) -> Void in
                
                self.performSegueToReturnBack()
            }))
            
            
            self.present(alert, animated: true, completion:nil)
            
            
        }
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
        newPhoto.image = image
        
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
        newPhoto.image = image
        self.dismiss(animated: true, completion: nil);
    }
    
    func setupTouchKeyboard() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        submitBtn.layer.cornerRadius = 10
        
        
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
    @objc func dismissKeyboard (){
        self.view.endEditing(true)
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showRules" {
            let vc = segue.destination as! Rules
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            vc.preferredContentSize = CGSize(width: 220, height: 268)
        }
    }
 

}

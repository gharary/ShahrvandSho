//
//  ShopDetailViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/11/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import ImageSlideshow
import MapKit
import HKProgressHUD
import MBProgressHUD


class ShopDetailViewController: UIViewController {
    
    @IBAction func cancel(_ sender: Any) {
        if  segueString == "showShopDetail" { // || segueString == "OffList" {
            _ = self.navigationController?.popViewController(animated: true)
            
        } else {
        
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    @IBOutlet weak var Group: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Tell : UILabel!
    @IBOutlet weak var Mobile: UILabel!
    @IBOutlet weak var Address: UILabel!
    @IBOutlet weak var Explain: UILabel!
    @IBOutlet weak var Fax: UILabel!
    @IBOutlet weak var nameUIView: UIView!
    @IBOutlet weak var commentUIView: UIView!
    @IBOutlet weak var detailUIView: UIView!
    @IBOutlet weak var infoUIView: UIView!
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainSV: UIScrollView!
    @IBOutlet weak var SlideShow: ImageSlideshow!
    @IBOutlet weak var offListContainer: UIView!
    
    var imgData:Dictionary<Int,String> = [:]
    let url = URL(string: "http://shahrvandsho.ir/api/seeker")
    var customHeight: CGFloat = 64
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var number:String = ""
    var storeID = 0
    let dispatchGroup = DispatchGroup()
    var tableData: [AnyObject]!
    var gjob: String = ""
    var groupStr: String = ""
    var sjob: String = ""
    var nameStr: String = ""
    var stell:String = ""
    var dtell: String = ""
    var mail: String = ""
    var ftell: String = ""
    var web: String = ""
    var place: String = ""
    var explan: String = ""
    var photo1: String = ""
    var photo2: String = ""
    var photo3: String = ""
    var height: Float = 0.0 //longitude
    var width: Float = 0.0 //latitude
    var shopImage : UIImage? = nil
    var shopImageString: String = ""
    var shopMap : Any? = nil
    var coordinate : CLLocationCoordinate2D? = nil
    var segueString: String? = ""
    var shopLocation = ""
    var shopName = ""
    var isAvail : Bool = false
    var initialLocation =  CLLocation(latitude: 36.836924, longitude: 54.437318)
    var imageData: [AnyObject]!
    var remoteStore = [InputSource]()
    var hud = HKProgressHUD()
    var limit = "10"
    var indexOfPageToRequest = 1
    var todoData :[String:AnyObject] = [:]
    {
        //A property Observer to refresh data in table any time this array changes
        didSet {
            
            DispatchQueue.main.async {
                self.loadDataOffList()
                _ = HKProgressHUD.hide(addedToView: (self.navigationController!.view)!, animated: true)
                //print(result)
                self.loadSliderImages()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        makeBorder(sender: mapUIView)
        makeBorder(sender: nameUIView)
        makeBorder(sender: commentUIView)
        makeBorder(sender: infoUIView)
        makeBorder(sender: detailUIView)
        makeBorder(sender: offListContainer)
        
        if segueString == "OffList" {
            hud = HKProgressHUD.show(addedToView: (self.navigationController?.view)!, animated: true)
            hud.label?.text = NSLocalizedString("در حال بارگذاری...", comment: "لطفا صبر کنید.")
            self.getStoreDataAlamo()
            
        } else {
            getOffAvailable()
        }
        
        if let FavArr = userDefaults.object(forKey: "favourite") as? [Int] {
            if (FavArr.contains(storeID)) {
                favBtn.image = UIImage(named: "FavRed")
            }
        }
        if self.tabBarController?.tabBar.isHidden == false {
            self.tabBarController?.tabBar.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.imageData = []
        self.tableData = []
        self.title = "جزئیات فروشگاه"
        self.hidesBottomBarWhenPushed = true
        
        
        SlideShow.setImageInputs(remoteStore)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShopDetailViewController.didTap))
        SlideShow.addGestureRecognizer(gestureRecognizer)
        SlideShow.contentScaleMode = .scaleAspectFit
    }
    
    func showHUD() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "در حال بارگذاری..."
        hud.dimBackground = true
    }
    func hideHUD() {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    func getOffAvailable()  {
        self.showHUD()
        let url = "http://shahrvandsho.ir/api/store/\(storeID)"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                //got an error in getting the data
                //                print("Error: loading data from server")
                let alert = UIAlertController(title: "خطا!", message: "خطا در اتصال به سرور", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                debugPrint(response.result.error!)
                self.loadDataNormal()
                self.loadSliderImages()
                self.setupViewWithoutContainer()
                self.hideHUD()
                return
                
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print("Didn't get data as JSON from API")
                print("Error: \(String(describing: response.result.error))")
                self.loadDataNormal()
                self.loadSliderImages()
                self.setupViewWithoutContainer()
                self.hideHUD()
                return
            }
            guard let _:[AnyObject] = jsonResult["discount"] as? [AnyObject] else {
                print("error parsing data, No Data")
                self.loadDataNormal()
                self.loadSliderImages()
                self.setupViewWithoutContainer()
                self.hideHUD()
                return
            }
            self.hideHUD()
            
            self.loadDataNormal()
            self.loadSliderImages()
            self.setupViewWithContainer()
            print("Off is available, running from Shop Detail.")
            
        }
        
        
    }
    
    func setupViewWithoutContainer() {
        self.offListContainer.isHidden = true
        self.infoUIView.topAnchor.constraint(equalTo: self.detailUIView.bottomAnchor, constant: 8).isActive = true
    }
    func setupViewWithContainer() {
        self.offListContainer.isHidden = false
        self.infoUIView.topAnchor.constraint(equalTo: self.offListContainer.bottomAnchor, constant: 8).isActive = true
        self.offListContainer.topAnchor.constraint(equalTo: self.detailUIView.bottomAnchor, constant: 8).isActive = true
    }
    @IBAction func callBtn(_ sender: Any) {
        if let urlNumber = URL(string: "tel://\(dtell)") {
            //UIApplication.shared.openURL(urlNumber)
            UIApplication.shared.open(urlNumber, options: [:], completionHandler: nil)
        }
    }
    @IBAction func shareBtn(_ sender:Any) {
        let message = "سلام. یه پیشنهاد شگفت انگیز دارم برات. شهروندشو رو نصب کن!"
        //Set the link to share.
        if let link = NSURL(string: "http://shahrvandsho.ir")
        {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    @IBOutlet weak var favBtn: UIBarButtonItem!
    let userDefaults = UserDefaults.standard
    var favArr =  [Int](repeatElement(0, count: 0))
    
    @IBAction func favoriteBtn(_ sender:Any) {
        //clearFavourite()
        //self.performSegueToReturnBack()
        if favBtn.image == UIImage(named: "heart") {
            favBtn.image = UIImage(named: "FavRed")
            if var favArr = userDefaults.object(forKey: "favourite") as? [Int] {
                userDefaults.removeObject(forKey: "favourite")
                favArr = favArr.filter { $0 != 0 }
                favArr.append(storeID)
                userDefaults.set(favArr, forKey: "favourite")
                //print(favArr)
            } else {
                
                favArr.append(storeID)
                userDefaults.set(favArr, forKey: "favourite")
                //print(favArr)
            }

        } else {
            var favArr = userDefaults.object(forKey: "favourite") as? [Int]
            favArr = favArr?.filter { $0 != storeID }
            userDefaults.removeObject(forKey: "favourite")
            //print(favArr!)
            userDefaults.set(favArr, forKey: "favourite")
            //print(favArr!)
            favBtn.image = UIImage(named: "heart")
            
        }
    
    }
    @IBAction func commentBtn(_ sender:Any) {
        
        let alert = UIAlertController(title: "نظرتان را وارد کنید", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "نام"
            textField.textAlignment = .right
        })
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "موضوع"
            textField.textAlignment = .right
        })
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "نظر"
            textField.textAlignment = .right
            
        })
        alert.addAction(UIAlertAction(title: "بازگشت", style: .cancel, handler: { (action) -> Void in
        
        self.dismiss(animated: true, completion: nil)
        }))
            
        alert.addAction(UIAlertAction(title: "باشه", style: .default, handler: { (action) -> Void in
            let name = alert.textFields![0] 
            let subject = alert.textFields![1]
            let comment = alert.textFields![2]
            
            self.postComment(name: name.text! ,subject: subject.text!,comment: comment.text!)
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func postComment(name:String, subject: String, comment: String) {
        let url = URL(string: "http://shahrvandsho.ir/api/comment")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let postString = "name=\(name)&subject=\(subject)&msg=\(comment)&adver_id=\(storeID)"
        
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            guard let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 else {
                // check for http errors
                let alert = UIAlertController(title: "", message: "در حال حاضر خطایی رخ داد. لطفا مجددا سعی کنید.!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(String(describing: response))")
                
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                
                _ = HKProgressHUD.hide(addedToView: (self.view), animated: true)
                let alert = UIAlertController(title: "", message: "نظر شما با موفقیت ثبت شد!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            print("responseString = \(String(describing: responseString))")
            
        }
        task.resume()
    }
    
    func clearFavourite() {
        userDefaults.removeObject(forKey: "favourite")
    }

    func makeBorder(sender: UIView) {
        sender.layer.cornerRadius = 10
        sender.clipsToBounds = true
        sender.layer.masksToBounds = true
        
    }
    
    

    
    
    func loadSliderImages() {
        
        
        for (_,value) in imgData {
            var photoUrl: String = "http://shahrvandsho.ir/"
            photoUrl.append(value)
            let url: URL! = URL(string: photoUrl)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url)
                {
                    DispatchQueue.main.async {

                    let img:UIImage! = UIImage(data: data)
                    if img != nil {
                        self.imageData.append(img)
                        self.remoteStore.append(ImageSource(image: img))
                        self.SlideShow.setImageInputs(self.remoteStore)
                        self.SlideShow.backgroundColor = UIColor.white
                        self.SlideShow.slideshowInterval = 3.0
                        self.SlideShow.pageControlPosition = PageControlPosition.insideScrollView
                        self.SlideShow.pageControl.currentPageIndicatorTintColor = UIColor.black
                        self.SlideShow.pageControl.pageIndicatorTintColor = UIColor.white
                        self.SlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
                        
                        }
                    }
                }
            })
 
            task.resume()
            
        }
        
        
    }
    
    func setupNavigation() {
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 44.0)
        let tLabel = UILabel(frame: frame)
        tLabel.text = "جزئیات فروشگاه"
        tLabel.textColor = UIColor.white
        tLabel.font = UIFont(name: "IRANSANSMOBILE", size: 16)
        tLabel.backgroundColor = UIColor.clear
        tLabel.adjustsFontSizeToFitWidth = true
        tLabel.textAlignment = .center
        
        self.navigationController?.navigationBar.topItem?.title = ""
        let backImage = UIImage(named: "back.jpg")
        self.navigationItem.titleView = tLabel
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
    }
    
    
    func loadDataNormal() {
        Group.text = gjob
        Name.text = nameStr
        Tell.text = stell
        Fax.text = ftell
        Mobile.text = dtell
        Address.text = place
        Explain.text = explan

        mapView.setRegion(shopMap as! MKCoordinateRegion, animated: true)
        let artwork = Artwork(title: nameStr, locationName: place, discipline: "", coordinate: coordinate!)
        mapView.addAnnotation(artwork)
        
        

    }
    let regionRadius: CLLocationDistance = 500

    
    func centerMapOnLocation(location: CLLocation) -> Any {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        return coordinateRegion
        
    }
    func loadDataOffList() {
        Group.text = todoData["gjob"] as? String
        
        Name.text = todoData["name"] as? String
        Tell.text = todoData["stell"] as? String
        Fax.text = todoData["ftell"] as? String
        Mobile.text = todoData["dtell"] as? String
        Address.text = todoData["place"] as? String
        Explain.text = todoData["explan"] as? String
        if (todoData["web"] != nil) {
            web = (todoData["web"] as? String)! }
        if (todoData["width"] != nil) {
            width = todoData["width"] as! Float }
        if (todoData["height"] != nil) {
            height = todoData["height"] as! Float }
        
        
        var i = 0
        self.imgData[i] = todoData["photo1"] as? String
        if todoData["photo2"] != nil {
            i += 1
            self.imgData[i] = todoData["photo2"] as? String
            
        }
        if todoData["photo3"] != nil {
            i += 1
            self.imgData[i] = todoData["photo3"] as? String
            
        }

        self.initialLocation = CLLocation(latitude: CLLocationDegrees(self.width) , longitude: CLLocationDegrees(self.height) )
        
        self.shopMap = self.centerMapOnLocation(location: self.initialLocation)
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.width), longitude: CLLocationDegrees(self.height))
        let artwork = Artwork(title: nameStr, locationName: place, discipline: "", coordinate: coordinate!)
        mapView.addAnnotation(artwork)
        
    }

    @objc func didTap() {
        SlideShow.presentFullScreenController(from: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showComment" {
                let destinationController = segue.destination as! CommentTVController
                destinationController.storeID = storeID
            if (segueString == "Category"  || segueString == "Favourite")  || segueString == "Search" || segueString == "OffList" {
                    destinationController.segueString = "showComment"
            }
        } else if segue.identifier == "OffListEmbed" {
            let dc = segue.destination as! OffListInDetailCollectionVC
            dc.storeID = String(storeID)
            
            
        }
    }
    

    func getStoreDataAlamo() {
        showHUD()
        let url = "http://shahrvandsho.ir/api/store/\(storeID)"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                //got an error in getting the data
                //                print("Error: loading data from server")
                let alert = UIAlertController(title: "خطا!", message: "خطا در اتصال به سرور", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "باشه!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                debugPrint(response.result.error!)
                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print("Didn't get data as JSON from API")
                print("Error: \(String(describing: response.result.error))")
                return
            }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("error parsing data, No Data")
                return
            }
            
            
            self.todoData = tempData[0] as! [String : AnyObject]
            self.setupViewWithContainer()
            self.hideHUD()
        }
        
    }



}

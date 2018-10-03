//
//  FavouriteTableVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/11/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import HKProgressHUD
import MapKit



class FavouriteTableVC: UITableViewController {

    
    @IBOutlet var tblDemo: UITableView!
    let userDefaults = UserDefaults.standard
    var FavArr : [Int]? = nil
    
    var limit = "10"
    var indexOfPageToRequest = 1
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!

    var endOfData:Bool = false
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject] = []
    {
        didSet {
            DispatchQueue.main.async {
                _ = HKProgressHUD.hide(addedToView: (self.view)!, animated: true)
                self.tblDemo.reloadData()
            }
        }
    }
    //var tableData : [ShopsData]!
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]

    var hud = HKProgressHUD()
    
    override func viewWillAppear(_ animated: Bool) {

        
    }
    func showAlert(){
        let alertMessage = UIAlertController(title: "", message: "", preferredStyle:.alert)
        alertMessage.addAction(UIAlertAction(title: "باشه", style: .destructive, handler: {action in
            //_ = self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
            
        }))
        //alertMessage.changeFont(view: self, font: "IRANSANSMOBILE")
        
        let titleFont = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE-Medium", size: 14.0)!]
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE-Light", size: 12.0)!]
        
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "موردی یافت نشد", attributes: messageFont)
        
        alertMessage.setValue(titleAttrString, forKey: "attributedTitle")
        alertMessage.setValue(messageAttrString, forKey: "attributedMessage")
        
        
    
        
        self.present(alertMessage, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)

        super.viewDidLoad()
        self.title = "علاقه مندی ها"
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        tableData = []
        cache = NSCache()
        
        hud = HKProgressHUD.show(addedToView: self.view, animated: true)
        hud.label?.text = NSLocalizedString("در حال بارگذاری...", comment: "لطفا صبر کنید.")
        guard let FavArr = userDefaults.object(forKey: "favourite") as? [Int] else {
            
            showAlert()
            return
        }
        if (FavArr.count) > 0 {
            tableData = []
            self.FavArr = FavArr
            getStoreData()
        } else {
            showAlert()
            
        }
        tblDemo.reloadData()
    }
    
    func getStoreData() {
        //DispatchQueue.main.async {
            
            for store in self.FavArr! {
                //print(store)
                self.getData(storeID: store)
           // }
        }
    }
    
    func getData( storeID: Int) {
        let storeID = storeID
        let url: String = "http://shahrvandsho.ir/api/store/\(storeID)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                
                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("error Parsing data. No data")
                debugPrint(jsonResult)
                return
            }
            
            
            for data in tempData {
                self.tableData.append(data)
            }
            self.tblDemo.reloadData()
        }

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableData.count > 0 {
            return tableData.count
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentItem = indexPath.row
        let cellIdentifier = "FavCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FavouriteTableViewCell
        var dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        cell.shopName.text = dictionary["gjob"] as? String
        cell.shoLocation.text = dictionary["place"] as? String
        cell.shopImage.image = UIImage(named: "placeholder")
        
        cell.shopImage.round()
        cell.shopName.numberOfLines = 2
        cell.shopName.minimumScaleFactor = 0.75
        cell.shopName.adjustsFontSizeToFitWidth = true
        
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil) {
            //print("Cache image used, no need to download it")
            cell.shopImage.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
            
        } else {
            var photo1Url = "http://shahrvandsho.ir/"
            photo1Url.append( dictionary["photo1"] as! String )
            
            let url:URL! = URL(string: photo1Url)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url)  {
                    DispatchQueue.main.async(execute: {() -> Void in
                        guard let updateCell = tableView.cellForRow(at: indexPath) as? FavouriteTableViewCell else { return }
                        //if ((updateCell) != nil )  {
                        let img:UIImage! = UIImage(data: data)
                        if img != nil {
                            updateCell.shopImage?.image = img
                            self.imgData[currentItem] = img
                            self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject) }
                        //}
                    })
                }
            })
            task.resume()
        }
        return cell
    }
    
    var initialLocation =  CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 500
    
    
    func centerMapOnLocation(location: CLLocation) -> Any {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        return coordinateRegion
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shopDetail" {
            if let indexPath = tblDemo.indexPathForSelectedRow   {
            
            let destinationController = segue.destination as! ShopDetailViewController
            
            let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
            
            destinationController.gjob = dictionary["gjob"] as! String
            destinationController.nameStr = dictionary["name"] as! String
            destinationController.place = dictionary["place"] as! String
            destinationController.dtell = dictionary["dtell"] as! String
            destinationController.explan = dictionary["explan"] as! String
            destinationController.ftell = dictionary["ftell"] as! String
            destinationController.web = dictionary["web"] as! String
            destinationController.segueString = "Favourite"
            
            destinationController.storeID = dictionary["row"]
            as! Int
            destinationController.shopImage = imgData[indexPath.row]
            guard var latitude = dictionary["width"], var longitude = dictionary["height"]
                
                else{
                    
                    return
            }
            var i = 0
            if latitude as! Float == 0 || longitude as! Float == 0 {
                //36.836934, 54.437318
                latitude = 36.836924 as AnyObject
                longitude = 54.437318 as AnyObject
            }
            initialLocation = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            
            destinationController.shopMap = centerMapOnLocation(location: initialLocation)
            destinationController.coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            if dictionary["photo2"] != nil {
                i += 1
                destinationController.imgData[i] = dictionary["photo2"] as? String
                
            }
            if dictionary["photo3"] != nil {
                i += 1
                destinationController.imgData[i] = dictionary["photo3"] as? String
                
                }
            }
        }
    }
}

extension UIAlertController {
    func changeFont(view: UIView, font:UIFont) {
        for item in view.subviews {
            if item.isKind(of: UICollectionView.self) {
                let col = item as! UICollectionView
                for  row in col.subviews{
                    changeFont(view: row, font: font)
                }
            }
            if item.isKind(of: UILabel.self) {
                let label = item as! UILabel
                label.font = font
            }else {
                changeFont(view: item, font: font)
            }
            
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let font = UIFont(name: "IRANSANSMOBILE-Medium", size: 14.0)
        changeFont(view: self.view, font: font! )
    }
}

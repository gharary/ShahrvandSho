//
//  CategoryDetailViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/17/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import MapKit
import Alamofire


private let reuseIdentifier = "ShopCell"

class CategoryShopsViewController: UICollectionViewController, UIPopoverPresentationControllerDelegate, CategorySelectionTableVCDelegate {
    func finishPassing(string: String) {
        indexOfPageToRequest = 1
        searchServer(term: string, order: "subgroup")
    }
    

    

    var valueSendFromSecondVC:String?
    
    let defaults: UserDefaults = UserDefaults.standard
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject] = []
    var filteredShops = [Shops]()
    var limit = "20"
    var indexOfPageToRequest = 1
    var selectedCatName: String = ""
    var selectedCatID: Int = 0
    var order: String = ""
    @IBOutlet weak var tblDemo: UICollectionView?
    
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
 
    
    let columns: CGFloat = 2.0
    let inset: CGFloat = 5.0
    let spacing: CGFloat = 5.0
    let lineSpacing:CGFloat = 5.0
    
    let url = URL(string: "http://shahrvandsho.ir/api/store")
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    var initialLocation =  CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 500
    
    
    func centerMapOnLocation(location: CLLocation) -> Any {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        return coordinateRegion
        
    }
    
    @IBAction func btnShowPopUp(_ sender: Any) {
        performSegue(withIdentifier: "showSubGroup", sender: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "فروشگاه ها"
        if self.tabBarController?.tabBar.isHidden == true {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = URLSession.shared
        task = URLSessionDownloadTask()
    
        self.cache = NSCache()
        if tableData.count == 0 {
            //showAlert()
        }
        searchServer(term: selectedCatName, order: order)
    }
    
    
    func showAlert(){
        let alertMessage = UIAlertController(title: "خطا", message: "موردی یافت نشد!", preferredStyle:.alert)
        alertMessage.addAction(UIAlertAction(title: "باشه", style: .destructive, handler: {action in
            _ = self.navigationController?.popViewController(animated: true)

        
        }))
        self.present(alertMessage, animated: true, completion: nil)
        
    }
    var searchTerm:String = ""
    var searchOrder:String = ""
    
    func searchServer(term: String = "", order:String = "desc") {
        
        var termNew = arabictoPersian(term: term)
        termNew = termNew.addingPercentEncoding(withAllowedCharacters: [])!
        searchTerm = termNew
        searchOrder = order
        let url = "http://shahrvandsho.ir/api/searchStore?limit=\(limit)&page=\(indexOfPageToRequest)&order=\(order)&term=\(termNew)"
        Alamofire.request(url).responseJSON { response in
            
            guard response.result.error == nil else {
                debugPrint(response.result.error!)
                self.showAlert()
                return}
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print(response.result.value!)
                self.showAlert()
                return }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else { //self.endOfData = true
                debugPrint(jsonResult)
                self.showAlert()
                return }
            self.tableData.removeAll()
            self.cache.removeAllObjects()
            
            for data in tempData {
                self.tableData.append(data)
            }
            
            self.tblDemo?.reloadData()
        }
        
    }
        
    func applyFilter() {
        
        filteredShops = tableData.filter { shop in
            let categoryMatch = shop["group"] as! String == selectedCatName
            //print(categoryMatch)
            
            return (categoryMatch == true)
            //            return (categoryMatch != nil) && (shop.category as NSString).contains(categories[name])
            } as! [Shops]
        
        tableData = filteredShops

    }
    func arabictoPersian(term: String) -> String{
        /*
         characters = [
         'ك' => 'ک',
         'دِ' => 'د',
         'بِ' => 'ب',
         'زِ' => 'ز',
         'ذِ' => 'ذ',
         'شِ' => 'ش',
         'سِ' => 'س',
         'ى' => 'ی',
         'ي' => 'ی',
         '١' => '۱',
         '٢' => '۲',
         '٣' => '۳',
         '٤' => '۴',
         '٥' => '۵',
         '٦' => '۶',
         '٧' => '۷',
         '٨' => '۸',
         '٩' => '۹',
         '٠' => '۰',
         ]
         
         */
        
        var newTerm = term.replacingOccurrences(of: "ك", with: "ک")
        newTerm = newTerm.replacingOccurrences(of: "دِ", with: "د")
        newTerm = newTerm.replacingOccurrences(of: "بِ", with: "ب")
        newTerm = newTerm.replacingOccurrences(of: "زِ", with: "ز")
        newTerm = newTerm.replacingOccurrences(of: "ذِ", with: "ذ")
        newTerm = newTerm.replacingOccurrences(of: "شِ", with: "ش")
        newTerm = newTerm.replacingOccurrences(of: "سِ", with: "س")
        newTerm = newTerm.replacingOccurrences(of: "ى", with: "ی")
        newTerm = newTerm.replacingOccurrences(of: "ي", with: "ی")
        
        
        
        return newTerm
        
    }

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    var endOfData:Bool = false
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            indexOfPageToRequest += 1
            if !endOfData {
                loadMoreData(index: indexOfPageToRequest)
                
            }
            
        }
    }
    
    func loadMoreData(index: Int) {
       
        let url = "http://shahrvandsho.ir/api/searchStore?limit=\(limit)&page=\(indexOfPageToRequest)&order=\(searchOrder)&term=\(searchTerm)"
        Alamofire.request(url).responseJSON { response in
            
            guard response.result.error == nil else {
                debugPrint(response.result.error!)
                return}
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print(response.result.value!)
                
                return }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else { //self.endOfData = true
                self.endOfData = true
                debugPrint(jsonResult)
                return }
            
            for data in tempData {
                self.tableData.append(data)
            }
            
            self.tblDemo?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //return shops.count
        guard tableData.count == 0 else {
            
            return self.tableData.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "ShopCell"
        let currentItem = indexPath.row
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ShopsCollectionViewCell
        
        
        let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        cell.shopName.text = dictionary["gjob"] as? String
        cell.shopLocation.text = dictionary["place"] as? String
        cell.shopImage.image = UIImage(named: "placeholder")
        imgData[currentItem] = UIImage(named: "placeholder")
        
        
        if (self.cache.object(forKey: ((indexPath as NSIndexPath).row as AnyObject)) != nil) {
            //print("Cache image used, no need to download it")
            cell.shopImage.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
            //imageData[indexPath.row] = (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage)!
            
        } else {
//            var photo1Url = "http://shahrvandsho.ir/"
//            photo1Url.append( dictionary["photo1"] as! String )
            var photo1Url:String = "http://shahrvandsho.ir/" , photoUrl2:String = "http://shahrvandsho.ir/",  photoUrl3:String = "http://shahrvandsho.ir/"
            
            if dictionary["photo1"] != nil {
                photo1Url.append( dictionary["photo1"] as! String )
                if dictionary["photo2"] != nil
                {
                    photoUrl2.append( dictionary["photo2"] as! String )
                    
                    if dictionary["photo3"] != nil{
                        photoUrl3.append( dictionary["photo3"] as! String )
        
                    }
                    
                }
            }
            
            let url:URL! = URL(string: photo1Url)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url)  {
                    DispatchQueue.main.async(execute: {() -> Void in
                        guard let updateCell = collectionView.cellForItem(at: indexPath) as? ShopsCollectionViewCell else {return}
                        
                            let img:UIImage! = UIImage(data: data)
                            if img != nil {
                            updateCell.shopImage?.image = img
                            self.imgData[currentItem] = img
                                self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject) }
                            
                        
                    })
                }
            })
            task.resume()
        }
        
        return cell
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubGroup" {
             let destinationVC = segue.destination as! CategorySelectionTableVC
            destinationVC.filter = true
            destinationVC.groupStr = selectedCatName
            destinationVC.groupID = selectedCatID
            destinationVC.delegate = self
            destinationVC.modalPresentationStyle = .popover
            destinationVC.popoverPresentationController?.delegate = self
            destinationVC.preferredContentSize = CGSize(width: 250, height: 300)
           // destinationVC.preferredContentSize = 
        }
        if segue.identifier == "showShopDetail" {
            let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            
            let destinationController = segue.destination as! ShopDetailViewController
            
            let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
            
            destinationController.gjob = dictionary["gjob"] as! String
            destinationController.nameStr = dictionary["name"] as! String
            destinationController.place = dictionary["place"] as! String
            destinationController.dtell = dictionary["dtell"] as! String
            destinationController.explan = dictionary["explan"] as! String
            destinationController.ftell = dictionary["ftell"] as! String
            destinationController.web = dictionary["web"] as! String
            destinationController.segueString = "showShopDetail"
            
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
extension CategoryShopsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int((collectionView.frame.width / columns) - (inset + spacing))
        _ = Int(collectionView.frame.height / 3.5)
        
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    
    
}
extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}






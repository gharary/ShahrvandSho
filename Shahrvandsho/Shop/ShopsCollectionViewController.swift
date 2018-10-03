//
//  ShopsCollectionViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import ImageSlideshow
import MapKit
import Alamofire


private let reuseIdentifier = "ShopCell"

class ShopsCollectionViewController: UICollectionViewController {


    var endOfData:Bool = false

    
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    //var tableData : [ShopsData]!
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    var isOffAvail:Bool = true
    var limit = "10"
    var indexOfPageToRequest = 1
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    

        
    let columns: CGFloat = 2.0
    let inset: CGFloat = 5.0
    let spacing: CGFloat = 5.0
    let lineSpacing:CGFloat = 5.0
    

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    var initialLocation =  CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 500
    
    
    func centerMapOnLocation(location: CLLocation) -> Any {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        return coordinateRegion
        
    }
    
    
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        session = URLSession.shared
        task = URLSessionDownloadTask()
            
        self.tableData = []
        self.cache = NSCache()
            
        refreshTableView()
            
        self.refreshCtrl = UIRefreshControl()
        self.refreshCtrl.addTarget(self, action: #selector(ShopsCollectionViewController.refreshTableView), for: .valueChanged)
        self.collectionView?.addSubview(refreshCtrl)
        self.collectionView?.alwaysBounceVertical = true
       

    }
    
    @objc func refreshTableView() {
        let url = URL(string: "http://shahrvandsho.ir/api/store?limit=\(limit)&page=\(indexOfPageToRequest)")

        task = session.downloadTask(with: url!, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
            
            if location != nil{
                let data:Data! = try? Data(contentsOf: location!)
                do{
                    let dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as AnyObject
                    self.tableData = dic.value(forKey : "data") as? [AnyObject]
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.collectionView?.reloadData()
                        
                        self.refreshCtrl?.endRefreshing()
                    })
                }catch{
                    print("something went wrong, try again")
                }
            }
        })
        task.resume()
        
        
        
    }
    func getOffAvailable(_ storeID: String)  {
        
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
            guard  jsonResult["discount"] as? [AnyObject] != nil else {
                print("error parsing data, No Data")
                
                return
            }
            
            self.isOffAvail = true
            print("Off is Available, Running from Shop Collection")
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "فروشگاه ها"
        isOffAvail = false


        
    }
        
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
        
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            guard tableData == nil else {
                return self.tableData.count
            }
            return 0
            
        }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            
            indexOfPageToRequest += 1
            if !endOfData {
                
                loadMoreData(index: indexOfPageToRequest)
            }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        let id:Int = dictionary["row"] as! Int
        
            
            //self.getOffAvailable(String(id))
            
        
        
        performSegue(withIdentifier: "showShopDetail", sender: self)
    }
    
    
    func loadMoreData(index:Int) {
        
        let url = "http://shahrvandsho.ir/api/store?limit=\(limit)&page=\(indexOfPageToRequest)"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {

                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("error Parsing data. No data")
                self.endOfData = true
                return
            }
            
            
            for data in tempData {
                self.tableData.append(data)
            }
            self.collectionView?.reloadData()
        }
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
            let cellImageLayer: CALayer? = cell.shopImage.layer
            cellImageLayer?.cornerRadius = 10 //cell.shopImage.frame.height /  3
            cellImageLayer?.masksToBounds = true
            cell.shopName.numberOfLines = 1
            cell.shopName.minimumScaleFactor = 0.2
            cell.shopName.adjustsFontSizeToFitWidth = true
            
            if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil) {
                //print("Cache image used, no need to download it")
                cell.shopImage.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
                
            } else {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShopDetail" {
            let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            if let navigationController = segue.destination as? UINavigationController {
                print("Navigation is set")
                let dc = navigationController.viewControllers[0] as! ShopDetailViewController
                
                let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
                /*
                DispatchQueue.main.async {
                    let id:Int = dictionary["row"] as! Int
                    self.getOffAvailable(String(id))
                }
                */
               
                
                
                if isOffAvail { dc.isAvail = true }
                dc.gjob = dictionary["gjob"] as! String
                dc.nameStr = dictionary["name"] as! String
                dc.place = dictionary["place"] as! String
                dc.dtell = dictionary["dtell"] as! String
                dc.explan = dictionary["explan"] as! String
                dc.ftell = dictionary["ftell"] as! String
                dc.web = dictionary["web"] as! String
                dc.storeID = dictionary["row"] as! Int
                dc.isAvail = isOffAvail
                dc.shopImage = imgData[indexPath.row]
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
            
            dc.shopMap = centerMapOnLocation(location: initialLocation)
            dc.coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
            dc.imgData[i] = dictionary["photo1"] as? String
            if dictionary["photo2"] != nil {
                i += 1
                dc.imgData[i] = dictionary["photo2"] as? String
                
            }
            if dictionary["photo3"] != nil {
                i += 1
                dc.imgData[i] = dictionary["photo3"] as? String
                
            }
            }
            
            

            }
    }

    
        // MARK: UICollectionViewDelegate
        
        /*
         // Uncomment this method to specify if the specified item should be highlighted during tracking
         override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
         return true
         }
         */
        
        /*
         // Uncomment this method to specify if the specified item should be selected
         override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
         return true
         }
         */
        
        /*
         // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
         override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
         return false
         }
         
         override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
         return false
         }
         
         override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
         
         }
         */
        
    }
extension ShopsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
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





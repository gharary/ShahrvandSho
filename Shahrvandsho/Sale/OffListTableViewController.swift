//
//  OffListTableViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/22/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire
import MapKit


private let reuseIdentifier = "OffCell"

//class OffListTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
class OffListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchControllerDelegate, UISearchDisplayDelegate, UISearchResultsUpdating{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    @IBOutlet var tblDemo: UITableView!
    var endOfData:Bool = false
    
    var tableData:[AnyObject]!
    {
        //A property Observer to refresh data in table any time this array changes
        didSet {
        tblDemo?.reloadData()
        }
    }
    var searchData:[AnyObject]!
    var tempData :[String:AnyObject] = [:]
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    var imgData:Dictionary<Int,UIImage> = [:]
    var limit = "20"
    var indexOfPageToRequest = 1
    
    var loadMoreStatus = false
    
    let ShahrvandShoURL = URL(string: "http://shahrvandsho.ir/api/off")
    
    var current:NSArray = []
    var myTest:NSDictionary = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController?.tabBar.isHidden == true {
            self.tabBarController?.tabBar.isHidden = false
        }
        /*if self.navigationController?.navigationBar.isHidden == true {
            self.navigationController?.isNavigationBarHidden = false
            //self.navigationController?.navigationBar.isHidden = false
        }*/
        self.title = "آخرین تخفیف ها"
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    func setupSearchController() {
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "جستجوی تخفیفی ها"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black ]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "جستجوی تخفیفی ها", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray ])
        
        if let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.font = UIFont(name: "IRANSansMobile-Light", size: 14.0)
            textFieldInsideSearchBar.textAlignment = .center
            
            if let backgroundView = textFieldInsideSearchBar.subviews.first {
                //background color
                backgroundView.backgroundColor = .white
                
                //rounded corner
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
                
                
            }
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        }
        searchController.searchBar.becomeFirstResponder()
        
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.tempData = [:]
        self.tableData = []
        self.searchData = []
        self.cache = NSCache()
        getDataAlamofire()
        tblDemo.delegate = self
        tblDemo.dataSource = self
        
        if #available(iOS 11.0, *) {
            setupSearchController()
        } else { setupSearchBar()   }
        
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.attributedTitle = NSAttributedString(string: "در حال دریافت اطلاعات...")
        
        refreshCtrl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tblDemo.refreshControl = refreshCtrl
        } else {
            tblDemo.addSubview(refreshCtrl)
        }
        
        tblDemo.rowHeight = 140
        tblDemo.tableFooterView?.isHidden = true
        
    }
    func setupSearchBar() {
        //self.extendedLayoutIncludesOpaqueBars = true
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.searchBar.delegate = self
        
        //deploying Search Scope
        searchController.searchBar.scopeButtonTitles = ["همه", "کالا", "اصناف","نزدیکترین"]
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "             دنبال چی میگردی؟           "
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.font = UIFont(name: "IRANSansMobile-Light", size: 12.0)
        
        //searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        //
        tblDemo.tableHeaderView = searchController.searchBar
        //navigationItem.searchController = searchController
        //tblDemo.tableHeaderView?.clipsToBounds = true
        definesPresentationContext = true
    }

    @objc func refresh(sender:AnyObject) {
        //tableData.removeAll()
        cache.removeAllObjects()
        //tempData.removeAll()
        getDataAlamofire()
        
        UIView.animate(withDuration: 20) {
                    if #available(iOS 10.0, *) {
                        self.tblDemo.refreshControl?.endRefreshing()
                    } else {
                        
                    }
        }
        self.tblDemo.reloadData()
        
    }


    func getDataAlamofire() {
        let url = "http://shahrvandsho.ir/api/off?limit=\(limit)&page=\(indexOfPageToRequest)"
        
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
            if jsonResult["data"] != nil {
                self.tableData = jsonResult["data"] as! [AnyObject]
            }

        }
    }
    

    
    func loadMoreData(index:Int) {
        
        let url = "http://shahrvandsho.ir/api/off?limit=\(limit)&page=\(indexOfPageToRequest)"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                //got an error in getting the data
               // print("Error: loading data from server")
                //debugPrint(response.result.error!)
                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
               // print("Didn't get data as JSON from API")
                //print("Error: \(String(describing: response.result.error))")
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                //print("error Parsing data. No data")
                self.endOfData = true
                return
            }
           
            
            for data in tempData {
                self.tableData.append(data)
            }
        }
    }
    
    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  searchController.searchBar.text != "" &&  searchData.count > 0 {
            return searchData.count
        } else {
            return tableData.count
        }
        
        
    }
    


      func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            
            indexOfPageToRequest += 1
            if !endOfData {
                loadMoreData(index: indexOfPageToRequest)
            }
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let index : Int = (tabBarController.viewControllers?.index(of: viewController))!
        if index == 2
        {
            let navigationController = viewController as? UINavigationController
            navigationController?.popToRootViewController(animated: true)
        }
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "OffListDetail", sender: self)
        UIView.animate(withDuration: 20) {
            
            self.tblDemo.deselectRow(at: indexPath, animated: true)
        }
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let currentItem = indexPath.row
        let cellIdentifier = "OffCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OffItemTableViewCell
        var dictionary: [String:AnyObject] = [:]
        if  searchController.searchBar.text != "" && searchData.count > 0 {
             dictionary = searchData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        } else {
        
             dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        }
        cell.shopName.text = dictionary["name"] as? String
        let percent = dictionary["per"]!
        cell.percentLabel.text = "تخفیف: \(percent)٪"
        let price = dictionary["cost"]!
        cell.priceLabel.text = "\(price) تومان"
        let remain = dictionary["remain"]!
        cell.shopOffPercent.text = "فرصت باقیمانده : \(remain)"
        cell.shopImage.image = UIImage(named: "placeholder")
        
        
        //cell.shopName.numberOfLines = 2
        cell.shopName.minimumScaleFactor = 0.75
        cell.shopImage.round()
        cell.shopName.adjustsFontSizeToFitWidth = true
        
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil) {
            //print("Cache image used, no need to download it")
            cell.shopImage.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
            
        } else {
            var photo1Url = "http://shahrvandsho.ir/"
            photo1Url.append( dictionary["photo"] as! String )

            let url:URL! = URL(string: photo1Url)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url)  {
                    DispatchQueue.main.async(execute: {() -> Void in
                        guard let updateCell = tableView.cellForRow(at: indexPath) as? OffItemTableViewCell else { return }
                        //if ((updateCell) != nil )  {
                            let img:UIImage! = UIImage(data: data)
                            if img != nil {
                                
                                updateCell.shopImage?.image = img
                                //updateCell.shopImage?.layer.cornerRadius = (img?.size.width)! / 2
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
    var storeID = 0
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OffListDetail" {
            
            
            if let indexPath = tblDemo.indexPathForSelectedRow {
                if let nav = segue.destination as? UINavigationController {
                    let destinationController = nav.viewControllers[0] as! ShopDetailViewController
                var dictionary: [String:AnyObject] = [:]
                if /*searchBar.isActive && searchBar.*/searchController.searchBar.text != "" && searchData.count > 0 {
                    dictionary = searchData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
                } else {
                    
                    dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
                }

                destinationController.segueString = "OffList"
                //destinationController.hidesBottomBarWhenPushed = true
            
                destinationController.storeID = dictionary["id"] as! Int
                storeID = dictionary["id"] as! Int
                
                }// if indexPath

            } // if segue
            
        } // end func prepare
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
        } else {
            tblDemo.reloadData()
        }
    }

    
    func filterContent(for searchText: String) {
        requestSearchFromServer(term: searchText)
        tblDemo.reloadData()
    }
    func requestSearchFromServer(term:String) {
        let params = ["limit":"10","page":"1","term":term] as [String : Any]
        var urlComponents = URLComponents(string: "http://shahrvandsho.ir/api/searchDis")
        var items = [URLQueryItem]()
        for (key,value) in params {
            items.append(URLQueryItem(name:key, value: value as? String))
        }
        urlComponents?.queryItems = items
        
        Alamofire.request(urlComponents!).responseJSON { response in
            
            guard response.result.error == nil else {
                debugPrint(response.result.error!)
                return}
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print(response.result.value!)
                
                return }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else { self.endOfData = true
                return }
            self.searchData.removeAll()
            //self.tableData.removeAll()
            self.cache.removeAllObjects()
            
            for data in tempData {
                self.searchData.append(data)
            }
            
            self.tblDemo.reloadData()
        }
    }
    
    } // end class

public extension UIView {
    public func round() {
        let width = bounds.width < bounds.height ? bounds.width : bounds.height
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: CGRect(x: bounds.midX - width / 2, y: bounds.midY - width / 2, width: width, height: width)).cgPath
        
        self.layer.mask = mask
    }
}


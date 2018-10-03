//
//  SearchViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/24/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Alamofire




class SearchViewController: UITableViewController, UISearchBarDelegate,UISearchControllerDelegate, CLLocationManagerDelegate {
    
    struct ShopType {
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
        var height: Float = 0.0
        var width: Float = 0.0

    }
    let searchController = UISearchController(searchResultsController: nil)
    let locationManager = CLLocationManager()
    

    var tableData:[AnyObject]!
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<AnyObject, AnyObject>!
    var endOfData:Bool = false
    var imgData:Dictionary<Int,UIImage> = [:]
    
    var filteredShops = [ShopType]()
    
    
    var shops = [ShopType]()
    var limit = "20"
    var indexOfPageToRequest = 1
    @IBOutlet var tblDemo: UITableView!
    @IBOutlet weak var barButton: UIBarButtonItem!

    @IBAction func cancelBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    var latitude :Double = 0.0
    var longitude : Double = 0.0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocationCoordinate2D = (manager.location?.coordinate)!
        latitude = location.latitude
        longitude = location.longitude
        
        manager.stopUpdatingLocation()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.resignFirstResponder()
        searchController.isActive = false
        self.navigationController?.navigationBar.topItem?.title = "جستجو"
    }
    override func viewDidAppear(_ animated: Bool) {
        //searchController.resignFirstResponder()
    }
    
    override func viewDidLoad(){
        shops = []
       
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self //as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSansMobile-Bold", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        barButton.setTitleTextAttributes([ NSAttributedStringKey.font: UIFont(name: "IRANSansMobile-Light", size: 12)!], for: UIControlState.normal)
        requestSearchFromServer(term: "", order: "")
        self.navigationController?.navigationBar.topItem?.title = "جستجو"
        super.viewDidLoad()
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.tableData = []
        self.cache = NSCache()
        
        if #available(iOS 11.0, *) {
            setupSearchController()
        } else { setupSearchBar() }
        

        UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)
     
        
    }
    func setupSearchController() {
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "دنبال چی میگردی؟"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.scopeButtonTitles = ["همه", "کالا", "اصناف","نزدیکترین"]
        searchController.searchBar.becomeFirstResponder()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black ]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = NSAttributedString(string: "جستجوی تخفیفی ها", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray ])
        /* searchController.searchBar.backgroundColor = UIColor.white
        for subview in searchController.searchBar.subviews {
            if subview.isMember(of: UISegmentedControl.self) {
                let scopeBar: UISegmentedControl = (subview as? UISegmentedControl)!
                scopeBar.tintColor = UIColor.blue
                //THis also your color for selected segment
            }
        } */
        let titleTextAttributesSelected = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
        
        // Normal text
        let titleTextAttributesNormal = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        
        
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
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        
        
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
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //updateSearchResultsForSearchController()
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
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
    
    func searchServer(term:String = "", order: String = "desc") {

        
        var termNew = arabictoPersian(term: term)
        termNew = termNew.addingPercentEncoding(withAllowedCharacters: [])!

        let url = "http://shahrvandsho.ir/api/searchStore?limit=\(limit)&page=\(indexOfPageToRequest)&order=\(order)&term=\(termNew)"
        Alamofire.request(url).responseJSON { response in
            
            guard response.result.error == nil else {
                debugPrint(response.result.error!)
                return}
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print(response.result.value!)
                
                return }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else { //self.endOfData = true
                debugPrint(jsonResult)
                return }
            self.tableData.removeAll()
            self.cache.removeAllObjects()
            
            for data in tempData {
                self.tableData.append(data)
            }
            
            self.tblDemo.reloadData()
        }

        
    }
    
    func requestSearchFromServer(term:String, order: String = "store") {
        
        let params = ["limit":limit,"page":indexOfPageToRequest,"term":term,"order":order,"lat":latitude,"lng":longitude] as [String : Any]
        
         var urlComponents = URLComponents(string: "http://shahrvandsho.ir/api/searchStore")
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
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else { //self.endOfData = true
                debugPrint(jsonResult)
                return }
            self.tableData.removeAll()
            self.cache.removeAllObjects()
            
            for data in tempData {
                self.tableData.append(data)
            }
            
            self.tblDemo.reloadData()
        }
    }
    
    
        func filterContentForSearchText(searchText: String, scope: String = "All") {
            var order:String = ""
            switch scope {
            case "کالا":
                order = "desc"
                
            case "اصناف":
                order = "store"
                
            case "نزدیکترین":
                order = "place"
                
            case "همه":
                order = ""
                
            default:
                order = ""
            }

            
            //requestSearchFromServer(term: searchText, order: order)
            searchServer(term: searchText, order: order)

            tblDemo.reloadData()
        }
        
        // MARK: - Table View
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            if tableData.count > 0 {
                
                return tableData.count
            } else {
                return 0
            }
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! searchItemCell
            let dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
            let currentItem = indexPath.row

            cell.shopName.text = dictionary["gjob"] as? String
            cell.shopLocation.text = dictionary["place"] as? String
            cell.shopImage.image = UIImage(named: "placeholder")
            if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil) {
                cell.shopImage.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
                
            } else {
                var photo1Url:String = "http://shahrvandsho.ir/" , photoUrl2:String = "http://shahrvandsho.ir/",  photoUrl3:String = "http://shahrvandsho.ir/"
                
                if dictionary["photo1"] != nil {
                    photo1Url.append( dictionary["photo1"] as! String )
                    if dictionary["photo2"] != nil
                    {
                        photoUrl2.append( dictionary["photo2"] as! String )
                        
                        if dictionary["photo3"] != nil{
                            photoUrl3.append( dictionary["photo3"] as! String ) }
                        
                    }
                }
                let url:URL! = URL(string: photo1Url)
                task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                    if let data = try? Data(contentsOf: url)  {
                        DispatchQueue.main.async(execute: {() -> Void in
                            guard let updateCell = tableView.cellForRow(at: indexPath) as? searchItemCell else { return }
                            
                           // let updateCell = tableView.cellForRow(at: indexPath) as! searchItemCell
                           // if (updateCell != nil) {
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
    var initialLocation =  CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 500

    func centerMapOnLocation(location: CLLocation) -> Any {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        return coordinateRegion
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if segue.identifier == "showDetail" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    if let navigationController = segue.destination as? UINavigationController {
                        //print("Navigation is set")
                        let destinationController = navigationController.viewControllers[0] as! ShopDetailViewController
                        let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
                        guard var latitude = dictionary["width"], var longitude = dictionary["height"] else{ return }
                    
                        var i = 0
                        if latitude as! Float == 0 || longitude as! Float == 0 {
                        //36.836934, 54.437318
                            latitude = 36.836924 as AnyObject
                            longitude = 54.437318 as AnyObject
                        }
                    
                        initialLocation = CLLocation(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                    
                        destinationController.shopMap = centerMapOnLocation(location: initialLocation)
                        destinationController.coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                        destinationController.imgData[i] = dictionary["photo1"] as? String
                        if dictionary["photo2"] != nil {
                            i += 1
                            destinationController.imgData[i] = dictionary["photo2"] as? String
                        
                        }
                        if dictionary["photo3"] != nil {
                            i += 1
                            destinationController.imgData[i] = dictionary["photo3"] as? String
                        
                        }

                        destinationController.segueString = "Search"
                        destinationController.gjob = dictionary["gjob"] as! String
                        destinationController.nameStr = dictionary["name"] as! String
                        destinationController.place = dictionary["place"] as! String
                        destinationController.dtell = dictionary["dtell"] as! String
                        destinationController.explan = dictionary["explan"] as! String
                        destinationController.ftell = dictionary["ftell"] as! String
                        destinationController.web = dictionary["web"] as! String
                        destinationController.shopImage = imgData[indexPath.row]

                        //destinationController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                        //destinationController.navigationItem.leftItemsSupplementBackButton = true
                        //destinationController.navigationController?.isNavigationBarHidden = true
                    }
                }
        }
    }
}
extension String
{
    func encodeUrl() -> String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
}
extension SearchViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
}





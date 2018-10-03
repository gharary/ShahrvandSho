//
//  CommentTVController.swift
//  
//
//  Created by Mohammad Gharary on 8/16/17.
//
//

import UIKit
import Alamofire
import HKProgressHUD
import MapKit


class CommentTVController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func returnBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var tblDemo: UITableView!
    let userDefaults = UserDefaults.standard
    var FavArr : [Int]? = nil
    
    var limit = "10"
    var indexOfPageToRequest = 1
    var storeID : Int = 0
    
    @IBOutlet weak var currentNavBar: UINavigationBar!
    var segueString: String? = ""

    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    var endOfData:Bool = false
    
    @IBAction func backBtn(_ sender: Any) {
        if segueString != "showComment" {
            self.dismiss(animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
            //_ = self.navigationController?.popToRootViewController(animated: true)
            
        }
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
        let alertMessage = UIAlertController(title: "", message: "موردی یافت نشد!", preferredStyle:.alert)
        alertMessage.addAction(UIAlertAction(title: "باشه", style: .destructive, handler: {action in
            _ = self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
            
        }))
        self.present(alertMessage, animated: true, completion: nil)
        
    }
    
    func setupNavigation() {

        currentNavBar.topItem?.title = "نظرات کاربران"
        currentNavBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        currentNavBar.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor).isActive = true
        currentNavBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64.0)
        tblDemo.translatesAutoresizingMaskIntoConstraints = false
        tblDemo.topAnchor.constraint(equalTo: currentNavBar.bottomAnchor).isActive = true
        tblDemo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tblDemo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tblDemo.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
       
        setupNavigation()
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        tableData = []
        cache = NSCache()
        
        hud = HKProgressHUD.show(addedToView: self.view, animated: true)
        hud.label?.text = NSLocalizedString("در حال بارگذاری...", comment: "لطفا صبر کنید.")
        getStoreData(storeID: storeID)

 
    }
    func getStoreData( storeID: Int) {
        let storeID = storeID
        let url: String = "http://shahrvandsho.ir/api/comment/\(storeID)"
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
                self.showAlert()
                return
            }
            
            
            for data in tempData {
                self.tableData.append(data)
            }
            self.tblDemo.reloadData()
        }
        
    }
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableData.count > 0 {
            return tableData.count
            
        } else {
            return 0
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cellIdentifier = "CommentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTVCell
        let dictionary = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        cell.name.text = dictionary["nf"] as? String
        cell.comment.text = dictionary["comment"] as? String
        cell.subject.text = dictionary["topic"] as? String
 

        return cell
    }


}

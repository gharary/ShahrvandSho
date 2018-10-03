//
//  CategoryCollectionViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CatCell"
let columns: CGFloat = 2.0
let inset: CGFloat = 8.0
let spacing: CGFloat = 8.0
let lineSpacing:CGFloat = 8.0


class CategoryCollectionViewController: UICollectionViewController {

    let defaults: UserDefaults = UserDefaults.standard
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    //var tableData : [ShopsData]!
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    
    
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    
    
    var categories:[Categories] = [Categories(id: 1, name:"دکوراسیون و مبلمان", image:"sofa.png" ), Categories(id: 2, name:"زیورآلات", image:"jewerly.png"), Categories(id: 3, name:"غذا و رستوران", image:"food.png"), Categories(id: 4, name:"لوازم الکترونیک", image:"electronic.png"),Categories(id: 5, name:"لوازم خانگی", image:"appliance.png"),Categories(id: 6, name:"مسکن و ساختمان", image:"building.png"),Categories(id: 7, name:"آرایشی و بهداشتی", image:"makeup.png"),Categories(id: 8, name:"بانک ها و موسسات", image:"bank.png"),Categories(id: 9, name:"تشریفات و مجالس", image:"party.png"),Categories(id: 10, name:"تفریحی و فرهنگی", image:"entertainment.png"),Categories(id: 11, name:"خدمات آموزشی", image:"educational.png"),Categories(id: 12, name:"خدمات اداری و تجاری", image:"office.png"),Categories(id: 13, name:"خدمات خودرو", image:"car.png"),Categories(id: 14, name:"خدمات درمانی", image:"medical.png"),Categories(id: 15, name:"خدمات شهری", image:"city.png"),Categories(id: 16, name:"خدمات منازل", image:"cleaning.png"),Categories(id: 17, name:"مسافرتی", image:"travel.png"),Categories(id: 18, name:"خرید روزانه", image:"dailyshop.png"),Categories(id: 19, name:"پوشاک", image:"clothes.png"),Categories(id: 20, name:"ورزشی", image:"sport.png"),Categories(id: 21, name:"سایر", image:"more.png")]
    
    let url = URL(string: "http://shahrvandsho.ir/api/store")
    
   var filteredShops = [Shops]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white];
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.tableData = []
        self.cache = NSCache()
        
        //refreshTableView()
        
        
        
        self.refreshCtrl = UIRefreshControl()
        self.refreshCtrl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        self.collectionView?.addSubview(refreshCtrl)
        self.collectionView?.alwaysBounceVertical = true

    }
    
    @objc func refreshTableView() {
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "دسته بندی فروشگاه ها"
        defaults.removeObject(forKey: "filterSubGroup")
    }

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "CatCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CategoryCollectionViewCell
    
        // Configure the cell
        cell.catImageView.image = UIImage(named: categories[indexPath.row].image)
        cell.backgroundColor = UIColor.white
        cell.catLabel.text = categories[indexPath.row].name
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShop" {
            let indexPaths : NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath : NSIndexPath = indexPaths[0] as! NSIndexPath
            //print(indexPath.row)
            
            let destinationController = segue.destination as! CategoryShopsViewController
            
            //destinationController.tableData = self.tableData
            destinationController.order = "group"
            destinationController.selectedCatName = categories[indexPath.row].name
            destinationController.selectedCatID = (categories[indexPath.row].id - 1)
            
            //destinationController.selectedCatName = categories[indexPath.row]
            
        }
    }

    
}
extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int((collectionView.frame.width / columns) - (inset + spacing))
        // let height = Int(collectionView.frame.height / 2)
        
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    
}



//
//  ShowSelfieCollectionVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 11/9/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "selfieCell"

class ShowSelfieCollectionVC: UICollectionViewController,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var favBtn: UIButton!
    
    var endData:Bool = false
    var refreshCtrl: UIRefreshControl!
    var tableData: [AnyObject]! {
        didSet { collectionView?.reloadData() }
    }
    var imageData: Array<UIImage> = []
    var imgData:Dictionary<Int,UIImage> = [:]
    var limit = "10"
    var indexOfPage = 1
    var tasl:URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    let columns: CGFloat = 2.0
    let inset:CGFloat = 5.0
    let spacing:CGFloat = 5.0
    let lineSpacing:CGFloat = 5.0
    var deviceToken:String = ""
    let defaults = UserDefaults.standard
    
    @IBAction func FavouriteBtnClicked(_ sender: UIButton) {
         
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.title = "سلفی"
        setupInitial()
        
        alamoRefreshTable()
    }

    func setupInitial() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.tableData = []
        self.cache = NSCache()
        refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(alamoRefreshTable), for: .valueChanged)
        collectionView?.refreshControl = refreshCtrl
        deviceToken = ""
        guard defaults.string(forKey: "deviceToken") != nil else { return }
        deviceToken = defaults.string(forKey: "deviceToken")!
        //print(deviceToken)
        
    }
    
    @objc func alamoRefreshTable() {
        indexOfPage = 1
        let url = "http://shahrvandsho.ir/api/photo?limit=\(limit)&page=\(indexOfPage)&code=\(deviceToken)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                print("error on connecting to URL!")
                self.refreshCtrl.endRefreshing()
                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print("Error on getting data!")
                self.refreshCtrl.endRefreshing()
                return
            }
            
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("error Parsing data. No data")
                self.refreshCtrl.endRefreshing()
                self.endData = true
                return
            }
            self.tableData.removeAll()
            
            for data in tempData {
                self.tableData.append(data)
            }
            self.collectionView?.reloadData()
            self.refreshCtrl.endRefreshing()
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        guard tableData == nil else {
            return tableData.count
        }
        return 2
    }
    var ID = 0
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShowSelfieCollectionCell
        let currentItem = indexPath.row
        // Configure the cell
        let dic = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        cell.selfieImage.image = UIImage(named: "placeholder")
        cell.selfieLocation.text = dic["place"] as? String
        cell.selfieLikeNo.text = dic["rank"] as? String
        cell.selfiePhotographer.text = dic["nf"] as? String
        ID = (dic["row"] as? Int)!
        cell.selfieLikeBtn.addTarget(self, action: #selector(likeBtnTapped), for: .touchUpInside)
        
        if dic["liked"] as? Int == 1 {
            cell.selfieLikeBtn.setImage(UIImage(named: "FavRed"), for: .normal)
        } else {
            cell.selfieLikeBtn.setImage(UIImage(named: "heart"), for: .normal)
        }
        imgData[currentItem] = UIImage(named: "placeholder")
        let cellImageLayer: CALayer? = cell.selfieImage.layer
        cellImageLayer?.cornerRadius = 10
        cellImageLayer?.masksToBounds = true
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil) {
            cell.selfieImage.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
        } else {
            var photoUrl:String = "http://shahrvandsho.ir/"
            
            if dic["photo"] != nil {
                photoUrl.append( dic["photo"] as! String )
                
            }
            let url:URL! = URL(string: photoUrl)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url)  {
                    DispatchQueue.main.async(execute: {() -> Void in

                            guard let updateCell = collectionView.cellForItem(at: indexPath) as? ShowSelfieCollectionCell else { return }
                            
                                let img:UIImage! = UIImage(data: data)
                                if img != nil {
                                    updateCell.selfieImage?.image = img
                                    self.imgData[currentItem] = img
                                    self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject) }
                                
                            
                        
                    })
                }
            })
            task.resume()
        }
    
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            indexOfPage += 1
            if !endData {
                loadMoreData(index: indexOfPage)
            }
        }
    }
    @objc func likeBtnTapped(sender:UIButton) {
        let point: CGPoint = sender.convert(CGPoint.zero, to: collectionView)
        let indexPath = collectionView?.indexPathForItem(at: point)
        //let cell = collectionView?.cellForItem(at: indexPath!) as? ShowSelfieCollectionCell
        let dic = self.tableData[(indexPath! as NSIndexPath).row] as! [String:AnyObject]
        
        likeFunc(selfiID: dic["row"] as! Int)
        /*
        //print(dic["row"]!)
        if cell?.selfieLikeBtn.image(for: .normal) == UIImage(named: "heart") {
            
            cell?.selfieLikeBtn.setImage(UIImage(named: "FavRed"), for: .normal)
            likeFunc(selfiID: dic["row"] as! Int)
        } else {
            
            cell?.selfieLikeBtn.setImage(UIImage(named: "heart"), for: .normal)
            likeFunc(selfiID: dic["row"] as! Int )
        }
        
        */
    }
    
    func likeFunc(selfiID:Int) {
        let url = "http://shahrvandsho.ir/api/rank?selfy_id=\(selfiID)&android=\(deviceToken)"
        Alamofire.request(url, method:.post).responseJSON { response in
            guard response.result.error == nil else {
                print("Error on connecting to like url")
                return
            }
            guard let jsonResult = response.result.value as? [String:Any] else {
                print("Error on getting like Data")
                return
            }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("Error on parsing like data. No Data!")
                //self.endData = true
                return
            }
            
            print(tempData)
            self.alamoRefreshTable()
            
        }
    }
    func loadMoreData(index: Int) {
        let url = "http://shahrvandsho.ir/api/photo?limit=\(limit)&page=\(indexOfPage)&code=\(deviceToken)"
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                print("Error on connecting to url")
                return
            }
            guard let jsonResult = response.result.value as? [String:Any] else {
                print("Error on getting Data")
                return
            }
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("Error on parsing data. No Data!")
                self.endData = true
                return
            }
            
            for data in tempData {
                self.tableData.append(data)
                
            }
            self.collectionView?.reloadData()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSelfieBig", sender: nil)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelfieBig" {
            let indexPaths:NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath:NSIndexPath = indexPaths[0] as! NSIndexPath
            let dic = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
            let vc = segue.destination as! ShowSelfieBigVC
            let cell = collectionView?.cellForItem(at: indexPath as IndexPath) as! ShowSelfieCollectionCell
            vc.username = dic["nf"] as! String
            vc.shopname = dic["place"] as! String
            vc.like = dic["rank"] as! String
            
            vc.image = cell.selfieImage.image
            
            if dic["liked"] as? Int == 1 {
               vc.likeImage =  UIImage(named: "FavRed")
            } else {
                vc.likeImage = UIImage(named: "heart")
            }
            
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.delegate = self
            //vc.preferredContentSize = CGSize(width: self.view.frame.width * 0.85, height: self.view.frame.height * 0.80)
            vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.60)
            //vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            vc.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            vc.popoverPresentationController?.sourceView = self.view
            
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
extension ShowSelfieCollectionVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int((collectionView.frame.width / columns) - (inset + spacing))
        _ = Int(collectionView.frame.height / 3.5)
        let height = Float( Float(width) * Float(1.35) )
        
        return CGSize(width: width, height: Int(height) )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}

//
//  OffListInDetailCollectionVC.swift
//  Shahrvandsho
//
//  Created by Mohammad Gharari on 11/15/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "OffListInDetailCell"

class OffListInDetailCollectionVC: UICollectionViewController, UIPopoverPresentationControllerDelegate {

    var storeID:String = ""
    var endOfData:Bool = false
    var tempData :[AnyObject] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    var task: URLSessionDownloadTask!
    var session: URLSession!
    
   
    var cache:NSCache<AnyObject, AnyObject>!
    var imgData:Dictionary<Int,UIImage> = [:]
    var limit = "10"
    var indexOfPageToRequest = 1
    
    var loadMoreStatus = false
    var tableData:[AnyObject]!
    {
        //A property Observer to refresh data in table any time this array changes
        didSet {
           collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataAlamofire()
        session = URLSession.shared
        task = URLSessionDownloadTask()
  
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
            guard let tempData:[AnyObject] = jsonResult["data"] as? [AnyObject] else {
                print("error parsing data, No Data")
                return
            }
           
            for data in tempData {
                if data["id"] as? Int == Int(self.storeID) {
                    self.tempData.append(data)
                }
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        guard tempData.count < 0  else {
            return tempData.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OffListCollectionCell
        let dic = self.tempData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        cell.offItemLabel.text = dic["name"] as? String
        let photo = dic["photo"]!
        let photoUrl = "http://shahrvandsho.ir/\(photo)"
        let url:URL! = URL(string: photoUrl)
        task = session.downloadTask(with: url, completionHandler: {(location, response, error) in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async(execute: {() -> Void in
                    guard let updateCell = collectionView.cellForItem(at: indexPath) as? OffListCollectionCell else {return}
                    
                    //if ((updateCell) != nil )  {
                    let img:UIImage! = UIImage(data: data)
                    if img != nil {
                        updateCell.offItemImage?.image = img
                    }
                    //}
                })
            }
        })
        task.resume()
        
        // Configure the cell
    
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OffDetailPopOver" {
            let dc = segue.destination as! ShowOffDetailInShopDetailVC
            let indexPaths:NSArray = self.collectionView!.indexPathsForSelectedItems! as NSArray
            let indexPath:NSIndexPath = indexPaths[0] as! NSIndexPath
            let dic = self.tempData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
            let cell = collectionView?.cellForItem(at: indexPath as IndexPath) as! OffListCollectionCell
            dc.image = cell.offItemImage.image
            dc.name = dic["name"] as! String
            dc.percent = dic["per"] as! String
            dc.price = dic["cost"] as! String
            dc.remainTime = dic["end"] as! String
            
            dc.modalPresentationStyle = .popover
            dc.popoverPresentationController?.delegate = self
            dc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.45)
            dc.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.minY , width: 0, height: 0)
        //dc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            dc.popoverPresentationController?.sourceView = self.view
            
            
            
            
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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

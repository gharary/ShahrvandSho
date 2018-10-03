//
//  EmployTableVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire


class EmployTableVC: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var tblDemo:UITableView!
    

    var cache:NSCache<AnyObject, AnyObject>!
    var imgData: Dictionary<Int,UIImage> = [:]
    var tableData:[AnyObject]!
    {
        didSet{
            tblDemo?.reloadData()
        }
    }
    var limit = "15"
    var indexOfPage = 1
    var endOfData:Bool = false
    var loadMoreStatus = false
    
    let resuseIdentifier = "Employ"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableData = []
        self.cache = NSCache()
        
        tblDemo.rowHeight = 100
        
        getDataAlamofire()
        
        
        
    }
    
    func getDataAlamofire() {
        let url = "http://shahrvandsho.ir/api/work?limit=\(limit)&page=\(indexOfPage)"
        
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
        
        let url = "http://shahrvandsho.ir/api/work?limit=\(limit)&page=\(indexOfPage)"
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard response.result.error == nil else {
                //got an error in getting the data
                print("Error: loading data from server")
                debugPrint(response.result.error!)
                return
            }
            
            guard let jsonResult = response.result.value as? [String:Any] else {
                print("Didn't get data as JSON from API")
                print("Error: \(String(describing: response.result.error))")
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
            self.tblDemo.reloadData()
        }
    }
    
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData.count
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            
            indexOfPage += 1
            if !endOfData {
                loadMoreData(index: indexOfPage)
            }
        }
    }
    
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tblDemo.indexPathForSelectedRow {
                let destination = segue.destination as! EmplyerDetailVC
                var dictionary: [String:Any] = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
                
                destination.titleStr = (dictionary["job"] as? String)!
                destination.timeStr = dictionary["time"] as! String
                destination.phoneStr = dictionary["stell"] as! String
                destination.mobileStr = dictionary["dtell"] as! String
                destination.paymentStr = dictionary["payment"] as! String
                destination.explainStr = dictionary["explain"] as! String
            }
            
            
            
        }
    }
 
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "popOverController") as! EmplyerDetailVC
//        vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 50, height: 100)
//        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = UIModalPresentationStyle.popover
//        let popOver = navController.popoverPresentationController
//        popOver?.delegate = self
//        
//        self.present(navController, animated: true, completion: nil)
//        
//        
//        
//    }
//    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath) as! EmployTableViewCell
        var dictionary: [String:AnyObject] = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        cell.jobSalary.text = dictionary["payment"] as? String
        cell.jobWorkTime.text = dictionary["time"] as? String
        cell.jobTitle.text = dictionary["job"] as? String
        cell.employImage.image = UIImage(named: "placeholder")
        cell.employImage.round()
        
        
        
        
        
        // Configure the cell...
        
        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

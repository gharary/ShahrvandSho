//
//  JobSeekTableVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 8/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import Alamofire

class JobSeekTableVC: UITableViewController {

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
    
    let resuseIdentifier = "JobSeek"
    var dataStatus:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableData = []
        self.cache = NSCache()
        
        tblDemo.rowHeight = 100
        
        dataStatus = getDataAlamofire()


    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !dataStatus {
            dataStatus = getDataAlamofire()
        }
    }
    
    func getDataAlamofire() -> Bool {
        let url = "http://shahrvandsho.ir/api/seeker?limit=\(limit)&page=\(indexOfPage)"
        var status:Bool = false
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
                status = true
            }
        }
        if status {
            return true
        }
        return false
        
    }
    
    func loadMoreData(index:Int) {
        
        let url = "http://shahrvandsho.ir/api/seeker?limit=\(limit)&page=\(indexOfPage)"
        
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tblDemo.indexPathForSelectedRow {
                let destination = segue.destination as! SeekerDetailVC
                var dictionary: [String:Any] = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
                
               destination.nameStr = dictionary["nf"] as! String
                destination.ageStr = dictionary["year"] as! String
                destination.educationStr = dictionary["degree"] as! String
                destination.mobileStr = dictionary["stell"] as! String
                destination.titleStr = dictionary["work"] as! String
                destination.paymentStr = dictionary["payment"] as! String
                destination.explainStr = dictionary["explain"] as! String
            }
            
            
            
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


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            
            let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath) as! JobSeekTableViewCell
            var dictionary: [String:AnyObject] = tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
            
            cell.title.text = dictionary["work"] as? String
        
            cell.jobSeekImage.image = UIImage(named: "placeholder")
            cell.jobSeekImage.round()
            cell.salary.text = dictionary["payment"]as? String
            cell.degree.text = dictionary["degree"] as? String
            
            
            
            

        // Configure the cell...

        return cell
    }
    

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

//
//  CategorySelectionTableVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 10/14/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

protocol CategorySelectionTableVCDelegate {
    func finishPassing(string: String)
}

class CategorySelectionTableVC: UITableViewController {

    var delegate: CategorySelectionTableVCDelegate?
    
    let defaults: UserDefaults = UserDefaults.standard
    var Sections = ["دکوراسیون و مبلمان","زیرآلات","غذا و رستوران","لوازم الکترونیک","لوازم خانگی","مسکن و ساختمان","آرایشی و بهداشتی","بانک ها و موسسات اعتباری","تشریفات مجالس","تفریحی و فرهنگی","خدمات آموزشی","خدمات تجاری و اداری","خدمات خودرو","خدمات درمانی","خدمات شهری","خدمات منازل","مسافرتی و حمل و نقل","خرید روزانه","پوشاک","ورزشی","سایر"]
    var items = [["فرش و موکت","طراحی و دکوراسیون","پرده فروشی","مبلمان","کالای خواب"],["عینک و ساعت فروشی","سکه و طلا فروشی"],["بستنی","آشپزخانه و تهیه غذا","غذاخوری","رستوران","کافه و کافی شاپ","فست فود"],["تلفن همراه","بازی کامپیوتری","لپتاپ و کامپیوتر","لوازم برقی و الکترونیک"],["لوازم خانه"],["مشاور املاک","تجهیزات ساختمان","مصالح ساختمانی"],["آرایشگاه و سالن زیبایی","عطر و ادکلن","پیرایشگاه مردانه","لوازم آرایشی"],["صرافی","بانک","موسسه مالی و اعتباری"],["ظروف کرایه","تالارهای پذیرایی","گل فروشی","عکاسی و آنلیه"],["سینما و فرهنگ","حوزه علمیه","مسجد و نمازخانه","شهربازی و پارک","کتاب فروشی و کتابخانه"],["آموزشگاه زبان","آموزشگاه رانندگی","سایر آموزشگاه ها","دانشگاه و موسسات","مهدکودک","مدارس"],["دفاتر حقوقی و مشاوره","تجهیزات اداری و فنی","چاپ و تبلیغات","لوازم تحریر"],["لوازم جانبی","تعمیرگاه ها","نمایشگاه خودرو","موتور و دوچرخه","پارکینگ","نمایندگی خودرو","کارواش","پمپ بنزین"],["داروخانه","تجهیزات پزشکی","دندان پزشکی","درمانگاه و بیمارستان","متخصص پوست، مو و زیبایی","عطاری","پزشک","مرکز بهداشت"],["ادارات دولتی و شهرداری","آتش نشانی","ثبت اسناد رسمی","بیمه","پلیس","خدمات ارتباطی و پیشخوان"],["خدمات نظافتی","تعمیرگاه لوازم خانگی","قالی شویی","سرمایشی و گرمایشی"],["تاکسی سرویس","آژانس مسافرتی","هتل و مسافرخانه","حمل و نقل باربری","پایانه، راه آهن و فروشگاه"],["سوپر مارکت","تعاونی مصرف","عمده فروشی","شیرینی سرا و خشکبار","محصولات غذایی","لبنیات و پروتئین","نانوایی","میوه فروشی"],["خشکشویی","بوتیک و فروشگاه","مزون","خیاطی و تولیدی","کیف، کفش و چمدان","پارچه سرا",],["سالن ورزشی","استخر","فروشگاه و لوازم ورزشی","زمین ورزشی"],["فروشگاه اسباب بازی","ابزار یراق","حیوانات","تابلو و قاب","شرکت ساختمانی","شرکت فناوری","شرکت خصوصی","محصولات کشاورزی","صنایع دستی","چادر مسافرتی","نجاری و صنایع چوب","کافی نت گیم نت","سایر موارد"]]
    
    var filter: Bool = false
    var groupStr: String = ""
    var groupID: Int = 0
    var filteredItems:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if filter {
            applyFilter()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func applyFilter() {
        filteredItems = items[groupID]
        
        //print(filteredItems)
    }
    
    @IBAction func btnPassData(_sender:Any) {
        delegate?.finishPassing(string: "Sent from CategorySelectionTableVC")
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filter {
            return groupStr
        }
        return self.Sections[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if filter {
            return 1
        }
        return Sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if filter {
            return filteredItems.count
        }
        return self.items[section].count
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "IRANSANSMOBILE-Bold", size: 14.0)
        header.textLabel?.textAlignment = .right
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)

        // Configure the cell...
        if filter {
            cell.textLabel?.text = self.filteredItems[indexPath.row]
        } else {
            
        
            cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("chosen section is: \(Sections[indexPath.section])")
        //print(items[indexPath.section][indexPath.row])
        if filter {
            defaults.set(filteredItems[indexPath.row], forKey: "filterSubGroup")
            //delegate?.setResult(valueSent: filteredItems[indexPath.row])
            delegate?.finishPassing(string: filteredItems[indexPath.row])
        }
        defaults.set(Sections[indexPath.section], forKey: "CatTitle")
        defaults.set(items[indexPath.section][indexPath.row], forKey: "SubCatTitle")
        self.dismiss(animated: true
            , completion: nil)
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

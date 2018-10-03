//
//  ShowOffDetailInShopDetailVC.swift
//  Shahrvandsho
//
//  Created by Mohammad Gharari on 11/16/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit

class ShowOffDetailInShopDetailVC: UIViewController {

    @IBOutlet weak var offImage: UIImageView!
    @IBOutlet weak var offName: UILabel!
    @IBOutlet weak var offPercent: UILabel!
    @IBOutlet weak var offRemainTime: UILabel!
    @IBOutlet weak var offPrice: UILabel!
    
    var image: UIImage? = UIImage(named: "placeholder")
    var name: String = ""
    var percent:String = ""
    var remainTime: String = ""
    var price: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offImage.image = image
        offName.text = name
        offPercent.text = percent + " %"
        offRemainTime.text = remainTime
        offPrice.text = price + "  تومان "
        offImage.layer.borderWidth = 4
        offImage.layer.cornerRadius = 10
        offImage.layer.borderColor = self.view.backgroundColor?.cgColor
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

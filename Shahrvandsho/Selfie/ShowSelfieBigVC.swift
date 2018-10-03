//
//  ShowSelfieBigVC.swift
//  Shahrvandsho
//
//  Created by Mohammad Gharari on 11/15/17.
//  Copyright © 2017 Mohammad Gharari. All rights reserved.
//

import UIKit

class ShowSelfieBigVC: UIViewController {

    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var shopnameLabel:UILabel!
    @IBOutlet weak var likeNoLabel:UILabel!
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    
    var username: String = ""
    var shopname: String = ""
    var like: String = "0"
    var image: UIImage? = UIImage(named: "placeholder")
    var likeImage: UIImage? = UIImage(named: "heart")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = username
        shopnameLabel.text = shopname
        likeNoLabel.text = like
        likeImageView.image = likeImage
        selfieImage.image = image
        selfieImage.layer.borderWidth = 4
        selfieImage.layer.cornerRadius = 10
        selfieImage.layer.borderColor = self.view.backgroundColor?.cgColor
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissView() {
            self.dismiss(animated: true, completion: nil)
    }



}

//
//  WallpaperViewController.swift
//  WallpaperPaging
//
//  Created by Brian on 2/17/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

class WallpaperViewController: UIViewController {


  @IBOutlet weak var wallpaperImageView: UIImageView!
    @IBOutlet weak var endBtn: UIButton!
    @IBAction func endButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var showButton: Bool = false
    
  var wallpaperImage: UIImage?
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    wallpaperImageView.image = wallpaperImage
    if (showButton) {
        endBtn.alpha = 1.0
        
    }
  }
    override func viewWillAppear(_ animated: Bool) {
        //endBtn.alpha = 0
        
    }

}

//
//  SplashViewController.swift
//  ShahrvandShoSplash
//
//  Created by Maryam Hoseini on ۲۰۱۷/۸/۶.
//  Copyright © ۲۰۱۷ Maryam Hoseini. All rights reserved.
//

import UIKit



class SplashViewController: UIViewController {


    @IBOutlet weak var ImgLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       /* UIView.animate(withDuration: 3, delay: 1, options: .curveEaseIn, animations: {
            self.ImgLogo.transform = CGAffineTransform (scaleX: 600, y: 500)
            //self.view.layoutIfNeeded()
            
        }, completion: nil )

        delay(time: 2, closure: {
        self.performSelector(onMainThread: #selector(self.showNavController), with: nil, waitUntilDone: false )
        })
 */
        
        
          UIView.animate(withDuration: 3 , animations: {
            self.ImgLogo.transform = CGAffineTransform (scaleX: 100 , y: 100)
          })
        
        delay(time: 2) {
         UIView.animate(withDuration: 5 , animations: {
           self.ImgLogo.transform = CGAffineTransform (scaleX: 600, y: 500)
            })
        }
        delay(time: 1) {
            self.performSelector(onMainThread: #selector(self.showNavController), with: nil, waitUntilDone: false )
            
        }
        
        
    }
    
   @objc func showNavController ()
   {
    performSegue(withIdentifier: "ShowFirst" , sender: self)
    }

    func delay(time : Double , closure : @escaping () ->()){
            DispatchQueue.main.asyncAfter(deadline: .now() + time ) {
                closure()
            }
    }
}

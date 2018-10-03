//
//  FirstViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/15/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import ImageSlideshow
import SideMenu

class FirstViewController: UIViewController, UICollectionViewDelegate , UITabBarControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet weak var currentNavBar: UINavigationBar!
    
    @IBAction func unwindToFirstVC(segue:UIStoryboardSegue) {}
    @IBAction func searchButton(_ sender: Any) {
        
    }
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    
    var imageData: [AnyObject]!
    var dataTask : URLSessionDataTask?

    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    var errorMessage = ""
    let url = URL(string: "http://shahrvandsho.ir/api/slider?type=index")
    
        
    let localStore = [ImageSource(imageString: "283")!]
    var remoteStore = [ImageSource(imageString: "283")!]
    

     override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        if self.tabBarController?.tabBar.isHidden == true {
            self.tabBarController?.tabBar.isHidden = false
        }
        if self.navigationController?.navigationBar.isHidden == true {
            self.navigationController?.isNavigationBarHidden = false
            //self.navigationController?.navigationBar.isHidden = false
        }
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)
        //self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64.0)
        //currentNavBar.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor).isActive = true
       //currentNavBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64.0)
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.imageData = []
        self.cache = NSCache()
        Networking()
        
        slideShow.setImageInputs(remoteStore)
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
        // Do any additional setup after loading the view, typically from a nib.
        slideShow.backgroundColor = UIColor.white
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = PageControlPosition.insideScrollView
        slideShow.pageControl.currentPageIndicatorTintColor = UIColor.black
        slideShow.pageControl.pageIndicatorTintColor = UIColor.white
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill

        //addSideBarMenu(leftMenuButton:nil,rightMenuButton: menuButton)

    }
    
    func setupNavigation() {
        //let menuRightNavigationController = UISideMenuNavigationController(rootViewController: self)
        let menuRightNavigationController = storyboard?.instantiateViewController(withIdentifier: "sideMenu") as! UISideMenuNavigationController
       SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuLeftNavigationController = nil
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: .right)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(menuTapped))
    }
    
    @objc func searchTapped() {
        let searchViewController = storyboard?.instantiateViewController(withIdentifier: "searchView")
        present(searchViewController!, animated: true, completion: nil)
    }
    
    @objc func menuTapped() {
        present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)

    }
    
    
    func Networking() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        remoteStore.removeAll()
        getSliderImages()
    }
    
    
    func getSliderImages() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "http://shahrvandsho.ir/api/slider") {
            urlComponents.query = "type=index"
            
            guard let url = urlComponents.url else { return }
            //print(url)
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer {self.dataTask = nil }
                
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    //print("Http Status Code: \(response.statusCode)")
                    self.updateSliderResults(data)
                }
                
            }
        }
        dataTask?.resume()
        
    }
    
    fileprivate func updateSliderResults(_ data: Data) {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        cache = NSCache()
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription) \n"
            return
        }
        //print("Serialization OK!")
        
        guard let array = response!["data"] as? [Any] else {
            errorMessage += "Dictionary does not contain Results key \n"
            return
        }
        //print("Parsing to array OK!")
        var index = 0
        for imageDictionary in array {
            
            //            if (cache.object(forKey: index as AnyObject) != nil) {
            //                remoteStore.append(ImageSource(image: cache.object(forKey: index as AnyObject) as! UIImage))
            //
            //            }
            
            if let imageDictionary = imageDictionary as? JSONDictionary {
                
                var photoUrl = "http://shahrvandsho.ir/"
                photoUrl.append(imageDictionary["photo"] as! String)
                let url:URL! = URL(string: photoUrl)
                //print(url)
                
                task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                    //print("tast is ok")
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async(execute: {() -> Void in
                            let img:UIImage! = UIImage(data: data)
                            if img != nil {
                                self.imageData.append(img)
                                self.cache.setObject(img, forKey: index as AnyObject)
                                self.remoteStore.append(ImageSource(image: img))
                                //self.imageTest.image = img
                                self.slideShow.setImageInputs(self.remoteStore)
                                
                                
                                //print("Appending Image \(index) was OK")
                                index += 1
                                
                            }
                        })
                    }else {
                        self.errorMessage += "Problem parsing imageDictionary \n"
                    } //else
                }) //session
                task.resume()
            } //parsing imageDictionary
        } //for
        
    }//func


}


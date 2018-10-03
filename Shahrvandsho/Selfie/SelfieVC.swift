//
//  SelfieVC.swift
//  ShahrVand
//
//  Created by Mohammad Gharari on 11/9/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import ImageSlideshow

class SelfieVC: UIViewController {
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    
    var imageData: [AnyObject]!
    var dataTask : URLSessionDataTask?
    var task : URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    var errorMessage:String = ""
    let localStore = [ImageSource(imageString: "283")!]
    var remoteStore = [ImageSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "سلفی"
        SetupInitial()
        initialSlider()
        getSliderImages()
    }

    
    
    func SetupInitial() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.imageData = []
        self.cache = NSCache()
    }
    
    func initialSlider() {
        slideShow.setImageInputs(localStore)
        slideShow.activityIndicator = DefaultActivityIndicator(style: .gray, color: .black)
        slideShow.slideshowInterval = 5.0
        slideShow.pageControlPosition = .insideScrollView
        slideShow.pageControl.currentPageIndicatorTintColor = .black
        slideShow.pageControl.pageIndicatorTintColor = .white
        slideShow.contentScaleMode = .scaleAspectFill
        
    }
    func getSliderImages() {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "http://shahrvandsho.ir/api/slider") {
            urlComponents.query = "type=self"
            
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

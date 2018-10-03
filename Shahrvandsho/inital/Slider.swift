//
//  Slider.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 7/13/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow


typealias JSONDictionary = [String: Any]
typealias QueryResult = (String) -> ()

var task: URLSessionDownloadTask!
var session: URLSession!
var cache:NSCache<AnyObject, AnyObject>!

var tabledata:[AnyObject]!
var imageData : [AnyObject]! = []

let urlString = URL(string: "shahrvandsho.ir/api/slider")
let url = URL(string: "http://shahrvandsho.ir/api/slider?type=index")


let defaultSession = URLSession(configuration: .default)
var dataTask : URLSessionDataTask?

var remoteStore = [ImageSource(imageString: "First")!, ImageSource(imageString: "Second")!, ImageSource(imageString: "Third")!, ImageSource(imageString: "Fourth")!]
var errorMessage = ""



func getData() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    DispatchQueue.main.async {
        task = session.downloadTask(with: url!, completionHandler: {( location:URL?, response: URLResponse?, error: Error?) -> Void in
            
            if location != nil {
                let data:Data! = try? Data(contentsOf: location!)
                do {
                    let dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as AnyObject
                    
                    imageData = dic.value(forKey: "data") as? [AnyObject]
                    
                    
                } catch {
                    //print("Serialization Error :\(error)")
                }
            }
            
            
        })
        task.resume()
        
        if imageData != nil {
            //print("Pasing to getSliderImage Func!")
            //getSliderImages()
        }
    }
    
    
}


func getSliderImages(type: String) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "http://shahrvandsho.ir/api/slider") {
            urlComponents.query = "type=\(type)" //"type=index"
            
            guard let url = urlComponents.url else { return }
            //print(url)
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer {dataTask = nil }
                
                if let error = error {
                    errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    //print("Http Status Code: \(response.statusCode)")
                    session = URLSession.shared
                    task = URLSessionDownloadTask()
                    cache = NSCache()
                    var response: JSONDictionary?
                    
                    do {
                        response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
                    } catch /*parseError*/ _ as NSError {
                        //errorMessage += "JSONSerialization error: \(parseError.localizedDescription) \n"
                        return
                    }
                    //print("Serialization OK!")
                    
                    guard let array = response!["data"] as? [Any] else {
                        //errorMessage += "Dictionary does not contain Results key \n"
                        return
                    }
                    //print("Parsing to array OK!")
                    var index = 0
                    remoteStore.removeAll()
                    for imageDictionary in array {
                        
                        if (cache.object(forKey: index as AnyObject) != nil) {
                            remoteStore.append(ImageSource(image: cache.object(forKey: index as AnyObject) as! UIImage))
                            
                        }
                        
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
                                            imageData.append(img)
                                            cache.setObject(img, forKey: index as AnyObject)
                                            remoteStore.append(ImageSource(image: img))
                                            
                                            //print("Appending Image \(index) was OK")
                                            index += 1
                                            
                                        }
                                    })
                                }else {
                                    //errorMessage += "Problem parsing imageDictionary \n"
                                } //else
                            }) //session
                            task.resume()
                           // print("task downloading images just resumed! ")
                        } //parsing imageDictionary
                    } //for
                    

                }
                
            }
        }
        dataTask?.resume()
        
    }





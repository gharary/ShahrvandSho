//
//  ViewController.swift
//  WallpaperPaging
//
//  Created by Brian on 2/17/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

enum WallpaperConstants {
  static let wallpaperCount = 5
}

class ViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  var pages: [WallpaperViewController] = []
    
  @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var currentNavBar: UINavigationBar!

    var showBtn:Bool = false
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.delegate = self
    var views: [String: UIView] = [:]
    views["view"] = view
    for i in 1...WallpaperConstants.wallpaperCount {
        if i == WallpaperConstants.wallpaperCount {
            showBtn = true
        }
      let fileName = String(format: "%02d.jpg", i)
      let wallpaperController = createWallpaper(withFileName: fileName)
      pages.append(wallpaperController)
      views["page\(i)"] = wallpaperController.view
        
    }
    scrollView.isPagingEnabled = true
    pageControl.numberOfPages = WallpaperConstants.wallpaperCount
    addConstraints(withViews: views)
  }


  fileprivate func addConstraints(withViews views: [String: UIView]) {
    let verticalConstraints =
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[page1(==view)]|", options: [], metrics: nil, views: views)
    NSLayoutConstraint.activate(verticalConstraints)
    var wallpaperConstraints = ""
    
    for i in 1...WallpaperConstants.wallpaperCount {
      wallpaperConstraints += "[page\(i)(==view)]"
    }
    let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|\(wallpaperConstraints)|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)
    NSLayoutConstraint.activate(horizontalConstraints)
  }
  
  fileprivate func createWallpaper(withFileName backgroundImageName: String) -> WallpaperViewController {
    let wallpaper = storyboard!.instantiateViewController(withIdentifier: "WallpaperViewController") as! WallpaperViewController
    wallpaper.wallpaperImage = UIImage(named: backgroundImageName)
    if showBtn {
        //wallpaper.endBtn.alpha = 1.0 
        wallpaper.showButton = true
    }
    wallpaper.view.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(wallpaper.view)
    
    addChildViewController(wallpaper)
    wallpaper.didMove(toParentViewController: self)
    
    return wallpaper
  }

  

}

extension ViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.bounds.width
    let pageFraction = scrollView.contentOffset.x / pageWidth
    
    pageControl.currentPage = Int(round(pageFraction))
  }
}


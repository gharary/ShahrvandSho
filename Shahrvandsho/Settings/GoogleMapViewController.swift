//
//  GoogleMapViewController.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 6/12/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit

class GoogleMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let camera = GMSCameraPosition.camera(withLatitude: 36.83, longitude: 54.43, zoom: 14)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        view = mapView
//        
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.position = CLLocationCoordinate2D(latitude: 36.83, longitude: 54.43)
//        marker.title = "Gorgan"
//        marker.snippet = "Iran"
//        marker.map = mapView
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

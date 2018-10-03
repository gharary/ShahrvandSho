//
//  Shops.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/16/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import Foundation
class Shops {
    var name = ""
    var category = ""
    var image = ""
    var location = ""
    var percent = " "
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    
    
    
    
    init(name: String, image:String, category:String, location:String, percent:String, latitude: Float, longitude: Float) {
        self.name = name
        self.image = image
        self.location = location
        self.category = category
        self.percent = percent
        self.latitude = latitude
        self.longitude = longitude
        
    }
}



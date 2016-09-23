//
//  MapLocation.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/22/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapLocation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    
}

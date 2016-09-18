//
//  YelpAPI.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/18/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import Foundation
import UIKit

struct Business {
    
    let name: String
    let latitide: String
    let longitude: String
    let rating: String
    //let image: UIImage
    
    static func from(dictionary: NSDictionary) -> Business? {
        
        guard let name = dictionary["name"] as? String,
        let coordinatesDict = dictionary["coordinates"] as? NSDictionary,
        let latitude = coordinatesDict["latitude"] as? String,
        let longitude = coordinatesDict["longitude"] as? String,
        let rating = dictionary["rating"] as? String
        
            else {
                return nil
        }
        
        // Add image code here later
        
        return Business(name: name, latitide: latitude, longitude: longitude, rating: rating)
        
    }
}



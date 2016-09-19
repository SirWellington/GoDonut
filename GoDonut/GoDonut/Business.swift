//
//  Business.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/19/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//


import Foundation
import UIKit

class Business {
    
    let name: String
    let coordinates: (latitude: Double, longitude: Double)
    let rating: Double
    let imageURL: String
    
    init(name: String, coordinates: (latitude: Double, longitude: Double), rating: Double, imageURL: String) {
        self.name = name
        self.coordinates = coordinates
        self.rating = rating
        self.imageURL = imageURL
        
    }
    
    static func fromDictionary(json: NSDictionary) -> Business? {
        
        guard let name = json["name"] as? String,
        let rating = json["rating"] as? Double,
        let jsonCoordinates = json["coordinates"] as? NSDictionary,
        let imageURL = json["image_url"] as? String
        else {
            return nil
        }
        
        guard let latitude = jsonCoordinates["latitude"] as? Double,
        let longitude = jsonCoordinates["longitude"] as? Double
            else {
                return nil
        }
        
        let coordinates = (latitude, longitude)
        
        return Business(name: name, coordinates: coordinates, rating: rating, imageURL: imageURL)
        
    }
    
}

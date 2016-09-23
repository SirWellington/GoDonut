//
//  Business.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/19/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//


import Foundation
import UIKit

struct Business {
    let id: String
    let name: String
    let coordinates: (latitude: Double, longitude: Double)
    let rating: Double
    let imageURL: String
    
}

extension Business {
    
    init?(json: NSDictionary){
        guard let name = json["name"] as? String,
            let id = json["id"] as? String,
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
        
        self.name = name
        self.id = id
        self.coordinates = coordinates
        self.rating = rating
        self.imageURL = imageURL
    }
    
}

extension Business {
    
    static func businesses(latitude: Double, longitude: Double, completionFunc: @escaping ([Business]) -> Void) {
        
        // Convert latitude and longitude to Strings
        let latAsString = String(latitude)
        let longAsString = String(longitude)
        
        // Create search URL for Yelp API
        let baseURL = URL(string: "https://api.yelp.com/v3/businesses/search")
        var searchURLComponents = URLComponents(url: baseURL!, resolvingAgainstBaseURL: false)!
        searchURLComponents.query = "term=donut"
        searchURLComponents.queryItems?.append(URLQueryItem(name: "latitude", value: latAsString) as URLQueryItem)
        searchURLComponents.queryItems?.append(URLQueryItem(name: "longitude", value: longAsString) as URLQueryItem)
        let searchURL = searchURLComponents.url!
        
        // Create Request
        let request = NSMutableURLRequest(url: searchURL)
        request.addValue(Configuration.token, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Create Session
        let session = URLSession.shared
        
        //Create Task
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            var businessArray: [Business] = []
            
            if let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                guard let result = jsonObject as? NSDictionary else { return }
                guard let businesses = result["businesses"] as? NSArray else { return }
                
                for businessObject in businesses {
                    guard let business = businessObject as? NSDictionary else { return }
                    if let businessFromStruct = Business(json: business) {
                        //print("business from struct")
                        businessArray.append(businessFromStruct)
                    } else {
                        print("didn't create business")
                    }
                }

            }
            completionFunc(businessArray)
        })
        
        dataTask.resume()


    }
}



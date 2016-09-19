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
    let image: String
    
    static func from(dictionary: NSDictionary) -> Business? {
        
        guard let name = dictionary["name"] as? String,
        let coordinatesDict = dictionary["coordinates"] as? NSDictionary,
        let latitude = coordinatesDict["latitude"] as? String,
        let longitude = coordinatesDict["longitude"] as? String,
        let rating = dictionary["rating"] as? String,
        let image = dictionary["image_url"] as? String
        
            else {
                return nil
        }
        
        // Add image code here later
        
        return Business(name: name, latitide: latitude, longitude: longitude, rating: rating, image: image)
        
    }
}

class Yelp {
    
    static let tokenURL: String = "https://api.yelp.com/oauth2/token"
    
        
    static func requestToken() {
        let headers = [
            "cache-control": "no-cache",
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "client_id=\(Configuration.appID)".data(using: String.Encoding.utf8)!)
        postData.append("&client_secret=\(Configuration.appSecret)".data(using: String.Encoding.utf8)!)
        postData.append("&grant_type=client_credentials".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/oauth2/token")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                guard let result = jsonObject as? NSDictionary else { return }
                guard let accessToken = result["access_token"] as? String else { return }
                print(accessToken)
            } catch {
                
            }
        })
        
        dataTask.resume()
    

    }
}



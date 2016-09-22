//
//  Review.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/22/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import Foundation
import UIKit

struct Review {
    let text: String
    let username: String
    let userImage: String
}

extension Review {
    init?(json: NSDictionary){
        guard let text = json["text"] as? String,
            let user = json["rating"] as? NSDictionary,
            let username = user["name"] as? String,
            let userImage = user["image_url"] as? String
            else {
                return nil
        }
        
        self.text = text
        self.username = username
        self.userImage = userImage
    }
}

extension Review {
    static func reviews(businessID: String, completionFunc: @escaping ([Review]) -> Void) {
        
        // Create Session
        let baseURL = URL(string: "https://api.yelp.com/v3/businesses/\(businessID)/reviews")
        let session = URLSession.shared
        let task = session.dataTask(with: baseURL!, completionHandler: { (data, response, error) -> Void in
            var reviewArray: [Review] = []
            
            guard let data = data else { print("no good"); return }
            
            print(data)
        
        completionFunc(reviewArray)
            
        })
        
        task.resume()
    }

}


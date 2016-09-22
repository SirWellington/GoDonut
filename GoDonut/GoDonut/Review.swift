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
}

extension Review {
    init?(json: NSDictionary){
        guard let text = json["text"] as? String,
            let user = json["user"] as? NSDictionary,
            let username = user["name"] as? String
            else {
                return nil
        }
        
        self.text = text
        self.username = username
    }
}

extension Review {
    static func reviews(businessID: String, completionFunc: @escaping ([Review]) -> Void) {
        
        // Create Session
        let reviewURL = URL(string: "https://api.yelp.com/v3/businesses/\(businessID)/reviews")
        
        let request = NSMutableURLRequest(url: reviewURL!)
        request.addValue(Configuration.token, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            var reviewArray: [Review] = []
            
            if let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                
                guard let result = jsonObject as? NSDictionary else { return }
                guard let reviewData = result["reviews"] as? NSArray else { return }
                //print(reviewData)
                for rev in reviewData {
                    guard let review = rev as? NSDictionary else { return }
                    //print(review)
                    if let reviewFromStruct = Review(json: review) {
                        //print("made this far")
                        reviewArray.append(reviewFromStruct)
                    } else {
                        print("problem parsing")
                    }
                }
            }
        
        completionFunc(reviewArray)
            
        })
        
        dataTask.resume()
    }

}


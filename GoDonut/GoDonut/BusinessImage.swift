//
//  BusinessImage.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/23/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import Foundation
import UIKit

struct BusinessImage {
    let imageArray: [UIImageView]
}

//extension BusinessImages {
//    init?(json: NSArray){
//        var jsonImages: [UIImage] = []
//        
//        for item in json {
//            if let imageURL = URL(string: item) {
//                if let data = try? Data(contentsOf: imageURL) {
//                    let image = UIImage(data: data)
//                    jsonImages.append(image)
//                }
//            }
//        }
//        
//        self.imageArray = jsonImages
//    }
//}

extension BusinessImage {
    static func images(businessID: String, completionFunc: @escaping ([UIImage]) -> Void) {
        
        // Create Session
        let reviewURL = URL(string: "https://api.yelp.com/v3/businesses/\(businessID)")
        
        let request = NSMutableURLRequest(url: reviewURL!)
        request.addValue(Configuration.token, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            var imageArray: [UIImage] = []
            
            if let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                
                guard let result = jsonObject as? NSDictionary else { return }
                guard let imageData = result["photos"] as? NSArray else { return }
                for img in imageData {
                    guard let imageString = img as? String else { return }
                    let imageURL = URL(string: imageString)
                    print(imageURL)
                    if let data = try? Data(contentsOf: imageURL!) {
                        let image = UIImage(data: data)
                        imageArray.append(image!)
                    }

                }
            }
            
            completionFunc(imageArray)
            
        })
        
        dataTask.resume()
    }

}

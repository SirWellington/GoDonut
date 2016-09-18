//
//  JSONTest.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/18/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import Foundation

class JSON {
    
    static let businesses = loadFile(name: "yelp")!
    
    private static func loadFile(name: String) -> String? {
        guard !name.isEmpty else { return nil }
        
        let bundle = Bundle(for: JSON.self)
        
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            return nil
        }
        
        return try? String.init(contentsOf: url)
    }
}

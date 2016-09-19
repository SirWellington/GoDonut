//
//  AllLocationsViewController.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/16/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import UIKit
import CoreLocation

class AllLocationsViewController: UITableViewController {
    
    var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    
    let testArray = ["A business name here", "Another name", "Sidecar Donut"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Yelp.requestToken()
        Yelp.getBusiness(lat: 37.786882, long: -122.399972)
        
        // Setup Location Manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return testArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell

        // Configure the cell...
        cell.businessNameLabel.text = testArray[indexPath.row]

        return cell
    }

}

extension AllLocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else {
            guard let latest = locations.first else { return }
            // Set the lat and long here - also update startLocation to current location
            let distanceInMeters = startLocation?.distance(from: latest)
            print(distanceInMeters)
            // Add code to query Yelp again if distance is large
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
}

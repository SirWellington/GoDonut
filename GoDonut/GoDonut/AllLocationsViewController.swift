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
    
    private let main = OperationQueue.main
    private let async: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        return operationQueue
    }()

    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    private var businesses: [Business] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Location Manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        // Setup Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.red
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        
        // Setup TableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140.0
        
        //reload()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let business = businesses[indexPath.row] 
        // Configure the cell...
        cell.businessNameLabel.text = business.name

        return cell
    }
    
    func reload() {
        print("reload called")
        
        async.addOperation {
            guard let myLocation = self.currentLocation else { return }
            //print("got location")
            let myLat = myLocation.coordinate.latitude
            let myLong = myLocation.coordinate.longitude
            
            Business.businesses(latitude: myLat, longitude: myLong) { businesses in
                self.businesses = businesses
                print(self.businesses)
                self.main.addOperation {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
            
        }

    }
    
}

extension AllLocationsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if currentLocation == nil {
            currentLocation = locations.first
            reload()
        } else {
            guard let latest = locations.first,
                let distanceInMeters = currentLocation?.distance(from: latest)
            else { return }
            
            if distanceInMeters > 200 {
                currentLocation = latest
                print("reloading because distance")
                reload()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
}

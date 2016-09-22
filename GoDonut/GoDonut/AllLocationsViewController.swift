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
    
    // Custom Spinner
    var customView: UIView!
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    private var businesses: [Business] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation Title Image
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "GoLogo"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        titleImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        navigationItem.titleView = titleImageView
                
        // Setup Location Manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        // Setup Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor(red: 0.878, green: 0.871, blue: 0.914, alpha: 1.000)
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        
        loadCustomRefreshContents()
        
        // Setup TableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 220.0
        
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
        
        if let imageURL = URL(string: business.imageURL),
            let image = loadImage(from: imageURL) {
            cell.businessImageView.image = image
        } else {
            cell.businessImageView.image = #imageLiteral(resourceName: "example")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBusiness = businesses[indexPath.row]
        performSegue(withIdentifier: "ShowDetail", sender: selectedBusiness)
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
    
    private func loadImage(from url: URL) -> UIImage? {
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {
        //let imageRect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        //CGContextDrawImage(context, imageRect, image.cgImage)
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    func loadCustomRefreshContents() {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents?[0] as! UIView
        customView.frame = (refreshControl?.bounds)!
        refreshControl?.addSubview(customView)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let businessDetailVC = segue.destination as! LocationDetailsViewController
            businessDetailVC.selectedBusiness = (sender as! Business)
            
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

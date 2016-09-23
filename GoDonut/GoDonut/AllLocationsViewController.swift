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
    
    // Custom Reloading Spinner
    var refreshLoadingView: UIView!
    var donutSpinner: UIImageView!
    //var isRefreshIconsOverlap = false
    var isRefreshingAnimating = false
    
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
        
        setupRefreshControl()
        
        // Setup TableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 220.0
        
    }
    
    // MARK: - Custom Refresh Controll
    // Setup initial views
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        refreshLoadingView.backgroundColor = UIColor.clear
        refreshControl?.backgroundColor = UIColor(red: 0.878, green: 0.871, blue: 0.914, alpha: 1.000)
        
        self.donutSpinner = UIImageView(image: #imageLiteral(resourceName: "donut-spinner"))
        self.refreshLoadingView.addSubview(donutSpinner)
        self.refreshLoadingView.clipsToBounds = true
        
        self.refreshControl?.addSubview(refreshLoadingView)
        
        refreshControl?.tintColor = UIColor.clear
        
        self.isRefreshingAnimating = false
        //self.isRefreshIconsOverlap = false
        
        refreshControl?.addTarget(self, action: #selector(self.reload), for: .valueChanged)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let reFreshWidth = self.tableView.frame.width
        var refreshBounds = self.refreshControl!.bounds
        let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y)
        let midX = self.tableView.frame.size.width / 2.0
        let donutHeight = self.donutSpinner.bounds.size.height
        let halfDonutHeight = donutHeight / 2
                
        let spinnerY = pullDistance / 2 - halfDonutHeight
        let spinnerX = midX - halfDonutHeight
        
        var spinnerFrame = self.donutSpinner.frame
        spinnerFrame.origin.x = spinnerX
        spinnerFrame.origin.y = spinnerY
        
        self.donutSpinner.frame = spinnerFrame
        
        refreshBounds.size.height = pullDistance
        self.refreshLoadingView.frame = refreshBounds
        
        if (self.refreshControl!.isRefreshing && !self.isRefreshingAnimating) {
            animateRefreshView()
        }
    }
    
    func animateRefreshView() {
        
        self.isRefreshingAnimating = true
        
        UIView.animate(
            withDuration: Double(0.3),
            delay: Double(0.0),
            options: UIViewAnimationOptions.curveLinear,
            animations: {
                // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                self.donutSpinner.transform = self.donutSpinner.transform.rotated(by: CGFloat(M_PI_2))
            },
            completion: { finished in
                // If still refreshing, keep spinning, else reset
                if (self.refreshControl!.isRefreshing) {
                    self.animateRefreshView()
                }else {
                    self.resetAnimation()
                }
            }
        )
    }
    
    func resetAnimation() {
        self.isRefreshingAnimating = false
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

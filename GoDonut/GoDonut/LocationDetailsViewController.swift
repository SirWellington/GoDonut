//
//  LocationDetailsViewController.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/22/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

class LocationDetailsViewController: UITableViewController {
    
    private let main = OperationQueue.main
    private let async: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        return operationQueue
    }()
        
    // Review array
    var reviews: [Review] = []
    var businessImages: [UIImage] = []
    
    // Business
    var selectedBusiness: Business!
    var businessLocations: [MKCoordinateRegion] = []
    
    // MapView
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup tableview
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        
        self.title = selectedBusiness.name
        
        // Setup map and location
        let businessLocation = CLLocation(latitude: selectedBusiness.coordinates.latitude, longitude: selectedBusiness.coordinates.longitude)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(businessLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.delegate = self
        
        // Add pin for business
        let pin = MapLocation(title: selectedBusiness.name, subtitle: "Rated: \(selectedBusiness.rating) donuts", coordinate: CLLocationCoordinate2D(latitude: selectedBusiness.coordinates.latitude, longitude: selectedBusiness.coordinates.longitude))
        
        mapView.addAnnotation(pin)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        reload()
    }
    
    func reload() {
        print("reload called")
        async.addOperation {
            
            Review.reviews(businessID: self.selectedBusiness.id) { fetchedReviews in
                self.reviews = fetchedReviews
                print("Got reviews")
            
                self.main.addOperation {
                    self.tableView.reloadData()
                    //self.refreshControl?.endRefreshing()
                }
            }
            
        }
        
        async.addOperation {
            BusinessImage.images(businessID: self.selectedBusiness.id) { fetchedImages in
                self.businessImages = fetchedImages
                print("Got images")
                print(self.businessImages.count)
                
                self.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return reviews.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let review = reviews[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
            
            cell.userLabel.text = "\(review.username) - "
            cell.reviewLabel.text = review.text
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesCell", for: indexPath) as! ImagesCell
            
            // Add location images
            cell.userPhotoScrollView.isPagingEnabled = true
            cell.userPhotoScrollView.alwaysBounceVertical = false
            
            if self.businessImages.count > 0 {
                for i in (0...self.businessImages.count - 1) {
                    let xPosition = Double(i) * Double(self.view.frame.size.width)
                    let imageView = UIImageView(frame: CGRect(x: xPosition, y: 0, width: Double(self.view.frame.size.width), height: 200))
                    imageView.image = businessImages[i]
                    imageView.contentMode = UIViewContentMode.scaleAspectFill
                    imageView.clipsToBounds = true
                    cell.userPhotoScrollView.addSubview(imageView)
                }
                
                cell.userPhotoScrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: 200)
            }
            
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        } else {
            return indexPath
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Customer Reviews"
        } else {
            return "Customer Images"
        }
    }

    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        guard let business = selectedBusiness else { return }
        var activities: [Any]  = []
        let message = "I'm \"Going 🍩\" at \(business.name)!"
        activities.append(message)
        
        let imageURL = URL(string: business.imageURL)
        if let image = loadImage(from: imageURL!) {
            activities.append(image)
        }
        
        let shareSheet = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        
        present(shareSheet, animated: true, completion: nil)
    }
    
    func setupScrollView() {
        
    }

}

extension LocationDetailsViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
}

extension LocationDetailsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let annotation = annotation as? MapLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            
            view.pinTintColor = UIColor(red: 0.604, green: 0.584, blue: 0.729, alpha: 1.000)
            
            return view
        }
        return nil
        
    }
    
    func loadImage(from url: URL) -> UIImage? {
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    

}





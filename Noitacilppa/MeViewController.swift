//
//  MeViewController.swift
//  Noitacilppa
//
//  Created by CHENCHIAN on 8/5/15.
//  Copyright (c) 2015 KICKERCHEN. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Parse

let UpdateUsInterval:NSTimeInterval = 15.0

class MeViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    var mapView: GMSMapView? = nil
    var meMarker: GMSMarker? = nil
    var updateTimer: NSTimer? = nil
    
    var meUpdated: Bool = false {
        didSet {
            if meUpdated != oldValue {
                println("meUpdate been set as: \(meUpdated)")
                if meUpdated == true {
                    println("current position: (\(meMarker!.position.latitude), \(meMarker!.position.longitude))")
                    mapView?.animateToLocation(meMarker!.position)
                    mapView?.animateToZoom(12)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView = GMSMapView(frame: self.view.bounds)
        mapView!.delegate = self
        //mapView!.myLocationEnabled = true
        self.view.insertSubview(mapView!, atIndex: 0)
        
        meMarker = GMSMarker()
        meMarker!.title = "Me"
        meMarker!.snippet = PFUser.currentUser()?.username
        meMarker!.icon = UIImage(named: "icon_me")
        meMarker!.map = mapView
        
        // Core Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
//        mapView?.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        
        // Start location update
        locationManager.startUpdatingLocation()
        
        //
        updateUs()
        
        // Setup Timer
        if updateTimer == nil {
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(UpdateUsInterval, target: self, selector: "updateUs", userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // pause location update
        meUpdated = false
        locationManager.stopUpdatingLocation()
        
        // turn off update timer
        if let timer = updateTimer {
            timer.invalidate()
            updateTimer = nil
        }
    }
    
    deinit {
//        mapView?.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "myLocation" {
            let myLocation = object.myLocation as CLLocation
            let myCoordinate = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude)
            mapView?.animateToLocation(myCoordinate)
            mapView?.animateToZoom(17)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onOptimusPrime(sender: UIButton) {
        
        println("current position: (\(meMarker!.position.latitude), \(meMarker!.position.longitude))")
        mapView?.animateToLocation(meMarker!.position)

    }

    
    // MARK: - CoreLocationManagerDelegate
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            locationManager.startUpdatingLocation()
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {

        // KVO for current position update
        if self.meUpdated == false {
            self.meUpdated = true
        }
        
        let curPos = (locations as! Array<CLLocation>).last!.coordinate
        if isSamePosition(meMarker!.position, positionB: curPos) == false {

            // update instance variable
            self.meMarker!.position = curPos

            
            // save
            let position: NSDictionary = [
                "latitude" : curPos.latitude,
                "longitude" : curPos.longitude
            ]
            let iAmHere = WhosThere(user: PFUser.currentUser()!, position: position)
            iAmHere.saveInBackgroundWithBlock { succeeded, error in
                
                if succeeded {
                    println("Current position been saved: \(curPos)")
                } else if let error = error {
                    self.showErrorView(error)
                }
            }

        }

    }
    
    
    // MARK: - GMSMapViewDelegate
    
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        if searchBar.isFirstResponder() { searchBar.resignFirstResponder() }
        
    }
    
    
    // MARK: - UISearchBarDelegate
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        println("searchBarShouldBeginEditing")
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("searchBarSearchButtonClicked")
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        println("searchBarTextDidEndEditing")
    }
    
    
    // MARK: - Helper Methods
    
    
    func isSamePosition(positionA: CLLocationCoordinate2D, positionB: CLLocationCoordinate2D) -> Bool {

        let epsilon: CLLocationDegrees = 0.001
        return (fabs(positionA.latitude - positionB.latitude) <= epsilon && fabs(positionA.longitude - positionB.longitude) <= epsilon) ? true : false
    }
    
    func updateUs() {
        
        let query = WhosThere.query()!
        query.findObjectsInBackgroundWithBlock { objects, error in
            
            if error == nil {
                
                if let objects = objects as? [WhosThere] {
                    self.updateWhosWho(objects)
                }
                
            } else if let error = error {
                
                self.showErrorView(error)
                
            }
        }
    }
    
    func updateWhosWho(whoList: [WhosThere]) {
        
        cleanMap()
        
        var results = NSMutableDictionary()
        
        for who in whoList {
            let latitude = who.position?.objectForKey("latitude") as! CLLocationDegrees
            let longitude = who.position?.objectForKey("longitude") as! CLLocationDegrees
            println("\(who.user.username)@(\(latitude),\(longitude)) at \(who.createdAt)")
        
            // Ignore self
            if who.user.username == PFUser.currentUser()?.username {
                continue
            }
            
            if let username = who.user.username {
      
                var newData = [
                    "latitude" : latitude,
                    "longitude": longitude,
                    "timestamp": who.updatedAt!
                ]
                
                // If old data exists, compare updateAt; otherwise, setValue
                if let oldData = results.valueForKey(username) as? NSDictionary {
                 
                    let oldUpdateAt = oldData.valueForKey("timestamp") as! NSDate
                    if oldUpdateAt.earlierDate(who.updatedAt!) == oldUpdateAt {

                        results.setValue(newData, forKey: who.user.username!)
                    }
                    
                } else {
                    
                    results.setValue(newData, forKey: who.user.username!)
                    
                }
            
            }
        }
        
        // Marker Time!
        results.enumerateKeysAndObjectsUsingBlock { (username, data, stop) in
            let position = CLLocationCoordinate2DMake(data.valueForKey("latitude") as! CLLocationDegrees, data.valueForKey("longitude") as! CLLocationDegrees)
            let marker = GMSMarker(position: position)
            marker.title = username as! String
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a dd/MM yyyy"
            let dateString = dateFormatter.stringFromDate(data.valueForKey("timestamp") as! NSDate)
            marker.snippet = "updated at: \(dateString)"
            
            marker.icon = UIImage(named: "icon_who")
            marker.map = self.mapView
        }
        
    }
    
    func cleanMap() {
        mapView!.clear()
        meMarker!.map = mapView
    }
}

//
//  ViewController.swift
//  what's what
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreMotion

struct Constants {
    let HFOV: Float
    let VFOV: Float
    let PhoneWidth: CGFloat
    let PhoneHeight: CGFloat
    
    init(hfov: Float, vfoc: Float, phoneWidth: CGFloat, phoneHeight: CGFloat) {
        HFOV = hfov
        VFOV = vfoc
        PhoneWidth = phoneWidth
        PhoneHeight = phoneHeight
    }
}

struct DistanceConstants {
    static let WithinRadius = CLLocationDistance(20000) // distance in meters
}

struct NearbyPointLabel {
    let indexIntoNearbyPointsWithAltitudeArray: Int!
    let xPosition: Int!
    let yPosition: Int!
}

class NearbyPointsViewController: UIViewController, CLLocationManagerDelegate, NearbyPointsManagerDelegate, LabelTapDelegate {
    
    var captureManager: CaptureSessionManager?
    
    var nearbyPointsManager: NearbyPointsManager!
    var nearbyPointsInLineOfSight: [NearbyPoint]?
    
    var currentHeading: CLLocationDirection?
    var currentZ: Double! = 0
    
    var DeviceConstants: Constants!
    
    // TEST!
    var nameLabel: UILabel! = UILabel()
    var nearbyPointCurrentlyDisplayed: NearbyPoint?
    // TEST!
    
    var locationManager: CLLocationManager! {
        didSet {
            println("location manager just set, view controller is \(self)")
            // TEST THIS!!!!!!!!!!!!
            locationManager.delegate = self
            // TEST THIS!!!!!!!!!!!!
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.headingAvailable() {
                locationManager.headingFilter = 0.1
                locationManager.headingOrientation = CLDeviceOrientation.LandscapeLeft
                locationManager.startUpdatingHeading()
            }
            println("location manager at the end of didset \(locationManager)")
        }
    }
    var motionManager: CMMotionManager! {
        didSet {
            motionManager.accelerometerUpdateInterval = 1/30
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "updateDistanceLimitRadius")
        self.view.addGestureRecognizer(swipeGesture)
        
        println("location manager is \(locationManager)")
        locationManager.startUpdatingLocation()
        
        captureManager?.addVideoInput()
        captureManager?.addVideoPreviewLayer()
        captureManager?.setPreviewLayer(self.view.layer.bounds, bounds: self.view.bounds)
        
        self.view.layer.addSublayer(captureManager?.previewLayer)
        
        captureManager?.captureSession?.startRunning()
        
        // TEST
        nameLabel.hidden = true
        self.view.addSubview(nameLabel)
        // TEST
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionHandler(motionData: CMAccelerometerData!, error: NSError!) {
        if self.nearbyPointsInLineOfSight != nil && self.nearbyPointsManager != nil && locationManager != nil && locationManager.heading != nil {
            let zData = motionData.acceleration.z
            if abs(zData - self.currentZ) > 0.01 {
                self.currentZ = zData
                if let heading = returnHeadingBasedInProperCoordinateSystem(locationManager.heading.trueHeading) {
                    println("heading: \(heading)")
                    for nearbyPoint in self.nearbyPointsInLineOfSight! {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            let labelAngle = CGFloat(nearbyPoint.angleToHorizon)
                            let phoneAngle = CGFloat(90 * zData)
                            let difference = labelAngle - phoneAngle
                            let VFOV = CGFloat(self.DeviceConstants.VFOV/2)
                            if difference > -1*VFOV && difference < VFOV {
                                let multiplier = (difference+VFOV)/(VFOV*2)
                                let yPosition = self.DeviceConstants.PhoneWidth - multiplier * self.DeviceConstants.PhoneWidth
                                let hfov: CGFloat = 28
                                var xDifference = CGFloat(heading - nearbyPoint.angleToCurrentLocation)
                                
                                if abs(xDifference) > 308 {
                                    if xDifference < 0 {
                                        xDifference = CGFloat(heading + (360.0 - nearbyPoint.angleToCurrentLocation))
                                    } else {
                                        xDifference = CGFloat((heading - 360.0) - nearbyPoint.angleToCurrentLocation)
                                    }
                                }
                                
                                if xDifference > -hfov && xDifference < hfov {
                                    let xMultiplier = CGFloat((xDifference + hfov)/(hfov*2))
                                    println("xMultiplier: \(xMultiplier)")
                                    let xPosition = xMultiplier * self.DeviceConstants.PhoneHeight
                                    nearbyPoint.label.hidden = false
                                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                                        nearbyPoint.label.frame = CGRectMake(xPosition, yPosition, CGFloat(17), CGFloat(16))
                                        }, completion: nil)
                                } else {
                                    nearbyPoint.label.hidden = true
                                }
                            } else {
                                nearbyPoint.label.hidden = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func returnHeadingBasedInProperCoordinateSystem(heading: Double?) -> CLLocationDirection? {
        if heading != nil {
            switch heading! {
                case 0...90:        return 90 - heading!
                case 90.01...180:   return 360 - (heading! - 90)
                case 180.01...270:  return 180 + (270 - heading!)
                case 270.01...360:  return 90 + (360 - heading!)
                default: return nil
            }
        }
        return nil
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("locationManager didFailWithError: \(error). Trying again...")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        if manager != nil {
            if let location = locations.last as? CLLocation {
                if nearbyPointsManager != nil {
                    let pointsManagerCurrentLocation2 = nearbyPointsManager
                    if let pointsManagerCurrentLocation = nearbyPointsManager.currentLocation {
                        if pointsManagerCurrentLocation.distanceFromLocation(location) > 1000 {
                            createNewNearbyPointsManager()
                            prepareForNewPointsAtLocation(location)
                            nearbyPointsManager.getGeonamesJSONData()
                        } else {
                            nearbyPointsManager.currentLocation = location
                            nearbyPointsManager.updateDistanceOfNearbyPointsWithAltitude()
                        }
                    } else {
                        prepareForNewPointsAtLocation(location)
                        nearbyPointsManager.getGeonamesJSONData()
                    }
                } else {
                    println("Something went wrong--nearbyPointsManager is nil")
                }
            }
        }
    }
    
    func createNewNearbyPointsManager() {
        nearbyPointsManager = NearbyPointsManager(delegate: self)
    }
    
    func prepareForNewPointsAtLocation(location: CLLocation!) {
        nearbyPointsInLineOfSight = [NearbyPoint]()
        nearbyPointsManager.currentLocation = location
    }
    
    func fetchingFailedWithError(error: NSError) {
        
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        println("assemebled points without altitude")
        
        // TEST
        if nearbyPointsManager != nil {
            nearbyPointsManager.getAltitudeJSONDataForEachPoint()
        } else{
            println("we lost the nearbyPoints manager")
        }
        // TEST
    }
    
    func retrievedNearbyPointWithAltitudeAndUpdatedDistance(nearbyPoint: NearbyPoint) {
        if nearbyPointsManager != nil {
            nearbyPointsManager.getElevationProfileDataForPoint(nearbyPoint)
        }
    }
    
    func confirmedCurrentLocationCanSeeNearbyPoint(nearbyPoint: NearbyPoint) {
        // TEST
        
        nearbyPointsInLineOfSight?.append(nearbyPoint)
        
        self.view.addSubview(nearbyPoint.label)
        
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: motionHandler)
        
        // TEST
    }
    
    
    // this function might be superfluous now
    func updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoints: [NearbyPoint]) {
        nearbyPointsInLineOfSight = nearbyPoints
    }
    // this function might be superfluous now
    
    // TEST
    func didReceiveTapForNearbyPoint(nearbyPoint: NearbyPoint) {
        nearbyPointCurrentlyDisplayed = nearbyPoint

        nameLabel.text = nearbyPoint.name
        nameLabel.sizeToFit()
        let width = nameLabel.frame.width
        let height = nameLabel.frame.height
        nameLabel.frame = CGRectMake(-width/2, -height, width, height)
        nameLabel.hidden = false
        nearbyPointCurrentlyDisplayed!.label.addSubview(nameLabel)
        
    }
    // TEST
}


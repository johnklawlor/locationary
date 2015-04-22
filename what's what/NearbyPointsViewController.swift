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

class NearbyPointsViewController: UIViewController, CLLocationManagerDelegate, NearbyPointsManagerDelegate {
    
    var captureManager: CaptureSessionManager?
    
    var nearbyPointsManager: NearbyPointsManager!
    var nearbyPointsWithAltitude: [NearbyPoint]?
    var nearbyPointsToShow: [Int]?
    var nearbyPointsSubviews: [UIImageView]?
    
    var currentLocation: CLLocation?
    var currentHeading: CLLocationDirection?
    var currentZ: Double?
    
    var DeviceConstants: Constants!
    
    var locationManager: CLLocationManager! {
        didSet {
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            
            if CLLocationManager.headingAvailable() {
                locationManager.headingOrientation = CLDeviceOrientation.LandscapeRight
                locationManager.startUpdatingHeading()
            }
        }
    }
    var motionManager: CMMotionManager! {
        didSet {
            motionManager.accelerometerUpdateInterval = 1/30
        }
    }
    
// m((18/75)*((distanceFromCurrentLocation)^2)/3.2808 // meters
// ((2/3)*((2.204*1.60934)^2))*0.304= 2.54977064 subtract this
// 352m high
// 349.450229 high
// 2204 far away
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nearbyPointsSubviews = [UIImageView]()
        
        captureManager?.addVideoInput()
        captureManager?.addVideoPreviewLayer()
        captureManager?.setPreviewLayer(self.view.layer.bounds, bounds: self.view.bounds)
        
        self.view.layer.addSublayer(captureManager?.previewLayer)
        
        var overlayImageView = UIImageView(image: UIImage(named: "overlaygraphic.png"))
        overlayImageView.frame = CGRectMake(50, 100, 17, 16)
        self.view.addSubview(overlayImageView)
        nearbyPointsSubviews = [overlayImageView]
        
        captureManager?.captureSession?.startRunning()
        
        if motionManager != nil && motionManager.accelerometerAvailable {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue())
                { (motionData, error) -> Void in
                    if self.nearbyPointsSubviews != nil {
                        for subview in self.nearbyPointsSubviews! {
                            NSOperationQueue.mainQueue().addOperationWithBlock() {
                                let labelAngle:CGFloat = 4.22
                                let phoneAngle = CGFloat(22 * motionData.acceleration.z)
                                let difference = labelAngle - phoneAngle
                                if difference > -16.32 && difference < 16.32 {
                                    let multiplier = (difference+16.32)/32.6475
                                    let yPosition = self.DeviceConstants.PhoneWidth - multiplier * self.DeviceConstants.PhoneWidth
                                    println("x is \(yPosition)")
                                    subview.frame = CGRectMake(CGFloat(400), yPosition, CGFloat(17), CGFloat(16))
                                }
                            }
                        }
                    }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        if newHeading.headingAccuracy < 0 {
            return;
        }
        
        let heading = returnHeadingBasedInProperCoordinateSystem(newHeading.trueHeading)
        
        if heading < 0 {
            return
        } else {
            currentHeading = heading
            showNearbyPointLabels()
        }
    }
    
    func showNearbyPointLabels() {
        println("currentHeading: \(currentHeading)")
        getIndicesOfPointsWithinFieldOfVisionOfCamera()
        
        if nearbyPointsToShow != nil {
            for nearbyPointIndex in nearbyPointsToShow! {
                let index = nearbyPointIndex
                if let nearbyPointToShow = nearbyPointsWithAltitude?[index] {
                    
                }
            }
        }

    }
    
    func getIndicesOfPointsWithinFieldOfVisionOfCamera() {
        if nearbyPointsWithAltitude != nil && currentLocation != nil && currentHeading != nil {
            for (index, nearbyPointWithAltitude) in enumerate(nearbyPointsWithAltitude!) {
                let nearbyPointLocation = nearbyPointWithAltitude.location
                let distanceFromCurrentLocation = currentLocation!.distanceFromLocation(nearbyPointLocation)
                
                if distanceFromCurrentLocation < DistanceConstants.WithinRadius {
                    println("currentHeading \(currentHeading)")
                    let lowerValidAngle = currentHeading! - Double(DeviceConstants.HFOV/2)
                    let upperValidAngle = currentHeading! + Double(DeviceConstants.HFOV/2)
                    
                    let y = CLLocation(coordinate: CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: nearbyPointLocation.coordinate.longitude), altitude: nearbyPointLocation.altitude, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
                    let dy = nearbyPointLocation.coordinate.latitude > currentLocation!.coordinate.latitude ? y.distanceFromLocation(nearbyPointLocation) : -(y.distanceFromLocation(nearbyPointLocation))
                    
                    let theta = (dy < 0) ? 360 - asin(dy/distanceFromCurrentLocation)*(180/M_PI) : asin(dy/distanceFromCurrentLocation)*(180/M_PI)
                    
                    if theta > lowerValidAngle && theta < upperValidAngle {
                        nearbyPointsToShow?.append(index)
                    }
                }
            }
        }
    }
    
    func returnHeadingBasedInProperCoordinateSystem(heading: Double!) -> CLLocationDirection! {
        switch heading {
            case 0...90:        return 90 - heading
            case 90.01...180:   return 360 - (heading - 90)
            case 180.01...270:  return 180 + (270 - heading)
            case 270.01...360:  return 90 + (360 - heading)
            default: return -1
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("locationManager didFailWithError: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        if manager != nil {
            if let location = locations.last as? CLLocation {
                if currentLocation != nil {
                    if currentLocation?.distanceFromLocation(location) > 1000 {
                        currentLocation = location
                        prepareForNearbyPointsWithAltitude()
                    }
                } else {
                    currentLocation = location
                    prepareForNearbyPointsWithAltitude()
                }
                
            }
        }
    }
    
    func prepareForNearbyPointsWithAltitude() {
        nearbyPointsWithAltitude = [NearbyPoint]()
        nearbyPointsManager = nil
        nearbyPointsToShow = [Int]()
    }
    
    func fetchingFailedWithError(error: NSError) {
        
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        
    }
    
    func retrievedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoint: NearbyPoint) {
        nearbyPointsWithAltitude?.append(nearbyPoint)
    }
}


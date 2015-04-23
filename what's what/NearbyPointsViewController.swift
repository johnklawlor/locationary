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

class NearbyPointsViewController: UIViewController, CLLocationManagerDelegate, NearbyPointsManagerDelegate {
    
    var captureManager: CaptureSessionManager?
    
    var nearbyPointsManager: NearbyPointsManager!
    var nearbyPointsWithAltitude: [NearbyPoint]?
    var nearbyPointsToShow: [Int]?
    var nearbyPointsSubviews: [UIImageView]?
    
    var currentHeading: CLLocationDirection?
    var currentZ: Double! = 0
    
    var DeviceConstants: Constants!
    
    var locationManager: CLLocationManager! {
        didSet {
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            
            if CLLocationManager.headingAvailable() {
//                locationManager.headingFilter
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
        
        locationManager.startUpdatingLocation()
        
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionHandler(motionData: CMAccelerometerData!, error: NSError!) {
        if self.nearbyPointsSubviews != nil {
            let zData = motionData.acceleration.z
            for subview in self.nearbyPointsSubviews! {
                if abs(zData - self.currentZ) > 0.01 {
                    self.currentZ = zData
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        let labelAngle:CGFloat = 8
                        let phoneAngle = CGFloat(90 * zData)
                        let difference = labelAngle - phoneAngle
                        let VFOV = CGFloat(self.DeviceConstants.VFOV/2)
                        if difference > -1*VFOV && difference < VFOV {
                            let multiplier = (difference+VFOV)/(VFOV*2)
                            let yPosition = self.DeviceConstants.PhoneWidth - multiplier * self.DeviceConstants.PhoneWidth
                            subview.hidden = false
                            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                                subview.frame = CGRectMake(CGFloat(400), yPosition, CGFloat(17), CGFloat(16))
                                }, completion: nil)
                        } else {
                            subview.hidden = true
                        }
                    }
                }
            }
        }

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
        locationManager.heading
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
        if nearbyPointsWithAltitude != nil && currentHeading != nil {
            for (index, nearbyPointWithAltitude) in enumerate(nearbyPointsWithAltitude!) {
                let nearbyPointLocation = nearbyPointWithAltitude.location
                
                if nearbyPointWithAltitude.distanceFromCurrentLocation < DistanceConstants.WithinRadius {
                    println("currentHeading \(currentHeading)")
                    let lowerValidAngle = currentHeading! - Double(DeviceConstants.HFOV/2)
                    let upperValidAngle = currentHeading! + Double(DeviceConstants.HFOV/2)
                    
//                    if theta > lowerValidAngle && theta < upperValidAngle {
//                        nearbyPointsToShow?.append(index)
//                    }
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
                if nearbyPointsManager != nil {
                    let currentLocation = nearbyPointsManager.currentLocation!
                    if currentLocation.distanceFromLocation(location) > 1000 {
                        prepareForNearbyPointsWithAltitude()
                        nearbyPointsManager.currentLocation = location
                        nearbyPointsManager.getGeonamesJSONData()
                    } else {
                        nearbyPointsManager.updateDistanceOfNearbyPointsWithAltitude()
                    }
                } else {
                    prepareForNearbyPointsWithAltitude()
                    nearbyPointsManager.currentLocation = location
                    nearbyPointsManager.getGeonamesJSONData()
                }
            }
        }
    }
    
    func prepareForNearbyPointsWithAltitude() {
        nearbyPointsManager = nil
        nearbyPointsManager = NearbyPointsManager()
        nearbyPointsManager.managerDelegate = self
        nearbyPointsWithAltitude = [NearbyPoint]()
        nearbyPointsToShow = [Int]()
    }
    
    func fetchingFailedWithError(error: NSError) {
        
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        
    }
    
    func retrievedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoint: NearbyPoint) {
        nearbyPointsWithAltitude?.append(nearbyPoint)
    }
    
    func updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoints: [NearbyPoint]) {
        nearbyPointsWithAltitude = nearbyPoints
    }
}


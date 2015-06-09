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
    
    var currentHeading: CLLocationDirection! = 0
    var currentZ: CLLocationDirection! = 0
    
    var DeviceConstants: Constants!
    
    // TEST!
    var nameLabel: UILabel! = UILabel()
    var nearbyPointCurrentlyDisplayed: NearbyPoint?
    // TEST!
    
    var locationManager: CLLocationManager! {
        didSet {
//            println("location manager just set, view controller is \(self)")
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
//            println("location manager at the end of didset \(locationManager)")
        }
    }
    var motionManager: CMMotionManager! {
        didSet {
            motionManager.accelerometerUpdateInterval = 1/30
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEST
        // can test these with view.gestures variable
        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveDoubleTapOnView:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOnView:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        self.view.addGestureRecognizer(tapRecognizer)
        
        var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "didReceiveLongPressOnView:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // TEST
        
//        println("location manager is \(locationManager)")
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
            let zDelta = abs(zData - self.currentZ)
            let heading = self.locationManager.heading.trueHeading
            let headingDelta = abs(heading - self.currentHeading!)
            self.currentHeading = heading
            
            if abs(zData - self.currentZ) > 0.01 {
                self.currentZ = zData
                if let deviceHeading = returnHeadingBasedInProperCoordinateSystem(locationManager.heading.trueHeading) {
//                    println("heading: \(deviceHeading)")
                    for nearbyPoint in self.nearbyPointsInLineOfSight! {
//                        println("nearbyPoint: \(nearbyPoint)")
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            let labelAngle = CGFloat(nearbyPoint.angleToHorizon)
                            let phoneAngle = CGFloat(90 * zData)
                            let yDifference = labelAngle - phoneAngle
                            let VFOV = CGFloat(self.DeviceConstants.HFOV/2)
                            if yDifference > (-1*VFOV)+10 && yDifference < (VFOV+10) {
                                let yMultiplier = (yDifference+VFOV)/(VFOV*2)
                                
                                var fuzz = CGFloat(arc4random_uniform(3))
                                fuzz -= 1
                                
                                let yPosition = (self.DeviceConstants.PhoneWidth - yMultiplier * self.DeviceConstants.PhoneWidth) + fuzz
                                let hfov = CGFloat(self.DeviceConstants.HFOV/2)
                                var xDifference = CGFloat(deviceHeading - nearbyPoint.angleToCurrentLocation)
                                
                                if abs(xDifference) > 308 {
                                    if xDifference < 0 {
                                        xDifference = CGFloat(deviceHeading + (360.0 - nearbyPoint.angleToCurrentLocation))
                                    } else {
                                        xDifference = CGFloat((deviceHeading - 360.0) - nearbyPoint.angleToCurrentLocation)
                                    }
                                }
                                
                                if xDifference > -hfov && xDifference < hfov {
                                    let xMultiplier = CGFloat((xDifference + hfov)/(hfov*2))
//                                    println("xMultiplier: \(xMultiplier)")
//                                    println("displaying nearbyPoint")
                                    let xPosition = xMultiplier * self.DeviceConstants.PhoneHeight
                                    nearbyPoint.label.hidden = false
                                    
                                    let animationDuration = 0.5/(pow(zDelta+headingDelta, 0.5))
                                    UIView.animateWithDuration(animationDuration,
                                        delay: 0,
                                        options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction,
                                        animations: {
                                            nearbyPoint.label.frame = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: nearbyPoint.label.frame.size)
                                        },
                                        completion: nil)
                                } else {
                                    nearbyPoint.label.hidden = true
//                                    println("hiding nearbyPoint")
                                }
                            } else {
                                nearbyPoint.label.hidden = true
//                                println("hiding nearbyPoint")
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
                    if let pointsManagerCurrentLocation = nearbyPointsManager.currentLocation {
                        if pointsManagerCurrentLocation.distanceFromLocation(location) > 1000 {
                            createNewNearbyPointsManager()
                            prepareForNewPointsAtLocation(location)
                            nearbyPointsManager.getGeonamesJSONData()
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
        nearbyPointsManager.communicator = GeonamesCommunicator()
        nearbyPointsManager.communicator?.geonamesCommunicatorDelegate = nearbyPointsManager
        nearbyPointsManager.parser = GeonamesJSONParser()
    }
    
    func prepareForNewPointsAtLocation(location: CLLocation!) {
        nearbyPointsInLineOfSight = [NearbyPoint]()
        nearbyPointsManager.currentLocation = location
    }
    
    func prepareToDetermineLineOfSight() {
        let elevationDataManager = ElevationDataManager()
        elevationDataManager.dataDelegate = nearbyPointsManager
        elevationDataManager.currentLocationDelegate = nearbyPointsManager
        nearbyPointsManager.elevationDataManager = elevationDataManager
    }
    
    func fetchingFailedWithError(error: NSError) {
        
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        println("assembled points without altitude")
        
        if nearbyPointsManager != nil {
            prepareToDetermineLineOfSight()
            nearbyPointsManager.determineIfEachPointIsInLineOfSight()
        } else{
            println("we lost the nearbyPoints manager")
        }
    }
    
    func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint) {

        nearbyPointsInLineOfSight?.append(nearbyPoint)
        
        println("added nearbyPoint: \(nearbyPoint)")
        
        // TEST
        self.view.addSubview(nearbyPoint.label)
        
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: motionHandler)
        
        // TEST
    }
    
    // TEST
    func didReceiveTapForNearbyPoint(nearbyPoint: NearbyPoint) {
        
        if let nearbyPointDisplayed = nearbyPointCurrentlyDisplayed {

            var labelToRemove = nameLabel
            
            UIView.animateWithDuration(0.25,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                    self.nameLabel.alpha = 0.0
                },
                completion: { [weak self] finished in
                    labelToRemove.removeFromSuperview()
                    labelToRemove = nil
            })
            
            if nearbyPointCurrentlyDisplayed === nearbyPoint {
                nearbyPointCurrentlyDisplayed = nil
            } else {
                makeNameLabelWithPoint(nearbyPoint)
            }
        
        } else {
            makeNameLabelWithPoint(nearbyPoint)
        }
        
    }
    
    func makeNameLabelWithPoint(nearbyPoint: NearbyPoint) {
        nameLabel = UILabel()
        nameLabel.text = nearbyPoint.name
        nameLabel.sizeToFit()
        let width = nameLabel.frame.width
        let height = nameLabel.frame.height
        let x = (nearbyPoint.label.frame.width - width)/2
        nameLabel.frame = CGRectMake(x, -height, width, height)
        nameLabel.alpha = 0.0
        nearbyPoint.label.addSubview(nameLabel)
        
        UIView.animateWithDuration(0.25,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                self.nameLabel.alpha = 1.0
            },
            completion: nil)
        
        nearbyPointCurrentlyDisplayed = nearbyPoint
    }
    
    // TEST
    
    
    
    func didReceiveTapOnView(gesture: UITapGestureRecognizer) {
        nameLabel.hidden = true
        nearbyPointCurrentlyDisplayed = nil
    }
    
    func didReceiveDoubleTapOnView(gesture: UITapGestureRecognizer) {
        let locationInView = gesture.locationInView(self.view)
        var nearbyPointsToExpand = [UIView]()
        
        println("locationInView: \(locationInView)")
        if nearbyPointsInLineOfSight != nil {
            switch gesture.state {
            case .Ended:
                motionManager.stopAccelerometerUpdates()
                for nearbyPoint in nearbyPointsInLineOfSight! {
                    let labelButton = nearbyPoint.label
                    println("labelButton frame's origin: \(labelButton.frame.origin)")
                    let labelButtonX = labelButton.frame.origin.x
                    let deltaX = labelButtonX - locationInView.x
                    if abs(deltaX) < 50.0 {
                        nearbyPointsToExpand.append(labelButton)
                    }
                }
                
                println("nearbyPointsToExpand: \(nearbyPointsToExpand.count)")
                var numberOfPointsToExpand = nearbyPointsToExpand.count
                
                if numberOfPointsToExpand > 1 {
                    nearbyPointsToExpand.sort({$0.frame.origin.x < $1.frame.origin.x})
                    numberOfPointsToExpand -= 1
                    for (index,pointToExpand) in enumerate(nearbyPointsToExpand) {
                        var newX = CGFloat(Double(index)/Double(numberOfPointsToExpand) * 30.0) - 30.0/2.0
                        if newX == 0 {
                            pointToExpand.transform = CGAffineTransformMakeScale(0.1, 0.1)
                            
                            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                                pointToExpand.transform = CGAffineTransformIdentity
                                }, completion: nil)
                        } else {
                            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                                pointToExpand.frame.origin = CGPoint(x: pointToExpand.frame.origin.x + newX, y: pointToExpand.frame.origin.y)
                                }, completion: nil)
                        }
                    }
                }
            default: break
            }
        }
    }
    
    func restartMotionManagerUpdates() {
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: motionHandler)
    }
    
    func didReceiveLongPressOnView(gesture: UILongPressGestureRecognizer) {
        restartMotionManagerUpdates()
    }
}
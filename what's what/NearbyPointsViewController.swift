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
import AVFoundation
import AddressBook

struct Constraints {
    var range: Double
    var max: Double
    var min: Double {
        return max - range
    }
    
    var rangeNotInUse: Double
    var maxNotInUse: Double
    var byDistance: Bool
}

struct Constants {
    var fieldOfVision: CGFloat
    let ConstantFieldOfVision: CGFloat
    let MaxVideoZoom: CGFloat
    let PhoneWidth: CGFloat
    let PhoneHeight: CGFloat
    let MarginForFieldOfVision: CGFloat = 20.0
    
    init(theFieldOfVision: Float, maxZoom: CGFloat, phoneWidth: CGFloat, phoneHeight: CGFloat) {
        fieldOfVision = CGFloat(theFieldOfVision)
        ConstantFieldOfVision = CGFloat(theFieldOfVision)
        MaxVideoZoom = maxZoom
        PhoneWidth = phoneWidth
        PhoneHeight = phoneHeight
    }
}

struct UIConstants {
    static let MaxPointsOnScreen = 100
    static let LabelBackgroundColor = UIColor(red: 255, green: 250, blue: 217, alpha: 0.3)
    static let NameLabelEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    static let LabelFont = UIFont(name: "Helvetica Neue", size: 18.0)
    static let LabelColor = UIColor.whiteColor()
    static let ProgressIndicatorLabelText = "Locating nearby points"
}

struct DistanceConstants {
    static let WithinRadius = CLLocationDistance(20000) // distance in meters
    static let NameLabelFontSize: CGFloat = 18.0
}

struct VideoConstants {
    static let PreferredMaxVideoZoom: CGFloat = 5.0
}

struct HeadingConstants {
    static let YAxisCorrection: Double = -70.0
}

class NearbyPointsViewController: UIViewController, CLLocationManagerDelegate, NearbyPointsManagerDelegate, LabelTapDelegate, UIGestureRecognizerDelegate, ScreenSizeDelegate, LocationManagerDelegate {
    
    var activityIndicatorView: UIView?
    var didCompleteFullRequest: Bool = false
	var didResignDuringRequest: Bool = false
    
    var motionQueue = NSOperationQueue.mainQueue()
    
    var captureManager: CaptureSessionManager?
    var captureDevice: AVCaptureDevice?
    var zoomFactor: CGFloat = 1.0
    
    var nearbyPointsManager: NearbyPointsManager!
    var nearbyPointsInLineOfSight: [NearbyPoint]?
    var distanceFarthestAway: CLLocationDistance = 5000
    var tallest: CLLocationDistance = 0
    var constraints: Constraints = Constraints(range: 5000, max: 100000, rangeNotInUse: 100, maxNotInUse: 1000, byDistance: true)
    var nearbyPointsWithinSetLimits: [NearbyPoint]? = []
    var nearbyPointsToExpand = [NearbyPoint]()
    var locationOfPanGesture = CGPoint()
    
    var currentHeading: CLLocationDirection! = 0
    var currentZ: CLLocationDirection! = 0
    
    var DeviceConstants: Constants!
    
    // TEST!
    var nameLabel: UITextView! = UITextView()
    var nearbyPointCurrentlyDisplayed: NearbyPoint?
    
    var horizontalPanRecognizer = UIPanGestureRecognizer()
    var verticalPanRecognizer = UIPanGestureRecognizer()
    
    var locationOfOneFingerPanGesture = CGPoint()
    
    // TEST!
    
    var locationManager: CLLocationManager! {
        didSet {
//            println("location manager just set, view controller is \(self)")
            // TEST THIS!!!!!!!!!!!!
            locationManager.delegate = self
            // TEST THIS!!!!!!!!!!!!
            locationManager.distanceFilter = 50
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.headingAvailable() {
                locationManager.headingFilter = 0.1
                locationManager.headingOrientation = CLDeviceOrientation.LandscapeLeft
                locationManager.startUpdatingHeading()
            }
//            println("location manager at the end of didset \(locationManager)")
            locationManager.startUpdatingLocation()
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
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "zoomIn:")
        pinchRecognizer.delegate = self
        self.view.addGestureRecognizer(pinchRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveDoubleTapOnView:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOnView:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        self.view.addGestureRecognizer(tapRecognizer)
        
        horizontalPanRecognizer = UIPanGestureRecognizer(target: self, action: "expandPointsWithPan:")
        horizontalPanRecognizer.delegate = self
        self.view.addGestureRecognizer(horizontalPanRecognizer)
        
        verticalPanRecognizer = UIPanGestureRecognizer(target: self, action: "changeDistanceOfPointsVisible:")
        verticalPanRecognizer.delegate = self
        self.view.addGestureRecognizer(verticalPanRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "returnPointsToMotionHandler")
        longPressRecognizer.delegate = self
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // TEST
        
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
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocityInView(self.view)
            
            if gestureRecognizer === horizontalPanRecognizer {
                return (fabs(velocity.y) < fabs(velocity.x))
            } else if gestureRecognizer === verticalPanRecognizer {
                return (fabs(velocity.y) > fabs(velocity.x))
            } else {
                return true
            }
        }
        else {
            return true
        }
    }
    
    func changeDistanceOfPointsVisible(gesture: UIPanGestureRecognizer){
        
        let locationInView = gesture.locationInView(self.view)
        
        switch(gesture.state) {
        case .Began:
            
            returnPointsToMotionHandler()
            
            locationOfOneFingerPanGesture = locationInView
            
        case .Changed:
            
            println("panning, range is \(constraints.range) and count \(nearbyPointsWithinSetLimits!.count)")
            
            var newRange: Double
            var newMax: Double
            
            if nearbyPointsWithinSetLimits!.count > 50 {
                newRange = constraints.range * 0.5
                if constraints.byDistance {
                    if newRange < 50 {
                        newRange = 50
                    }
                } else {
                    if newRange < 10 {
                        newRange = 10
                    }
                }
            } else if nearbyPointsWithinSetLimits!.count < 25 {
                newRange = constraints.range * 2
                if constraints.byDistance {
                    if newRange > 5000 {
                        newRange = 5000
                    }
                } else {
                    if newRange > 100 {
                        newRange = 100
                    }
                }
            } else {
                newRange = constraints.range
            }
            
            let deltaY = (locationInView.y - locationOfOneFingerPanGesture.y)/3.5
            
            if abs(deltaY) > 1.0 {
                
                locationOfOneFingerPanGesture = locationInView
                
                if constraints.byDistance {
                    let tempNewMax = constraints.max - Double(deltaY) * 1000
                    if tempNewMax < 5000 {
                        newMax = 5000
                    } else if tempNewMax > distanceFarthestAway {
                        newMax = distanceFarthestAway
                    } else {
                        newMax = tempNewMax
                    }
                } else{
                    let tempNewMax = constraints.max - Double(deltaY) * 30
                    if tempNewMax < 100 {
                        newMax = 100
                    } else if tempNewMax > tallest {
                        newMax = tallest
                    } else {
                        newMax = tempNewMax
                    }
                }
                
                if nearbyPointsInLineOfSight != nil {
                    filterPointsInLineOfSightWithNewMax(newMax, AndNewRange: newRange, AndByDistance: constraints.byDistance)
                }
            }
            motionManager.restartMotionManager(motionHandler)
        default:
            break
        }
        
    }
    
    func filterPointsInLineOfSightWithNewMax(newMax: Double, AndNewRange newRange: Double, AndByDistance byDistance: Bool) {
        let newMin = newMax - newRange
        println("\(newMax), \(newMin), \(byDistance)")
        motionManager.stopAccelerometerUpdates()
        var pointsToRemove: [NearbyPoint]
        
        // when we change the range, we want to remove all the points in nearbyPointsWithinSetLimits that are less than the new min value
        if newMax < constraints.max {
            if constraints.byDistance {
                pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.distanceFromCurrentLocation > newMax && $0.distanceFromCurrentLocation < self.constraints.max})
            } else {
                pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.location.altitude > newMax && $0.location.altitude < self.constraints.max})
            }
        } else {
            if constraints.byDistance {
                pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.distanceFromCurrentLocation > self.constraints.min && $0.distanceFromCurrentLocation < newMin})
            } else {
                pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.location.altitude > self.constraints.min && $0.location.altitude < newMin})
            }
        }
        removePointsFromScreen(pointsToRemove)
        if constraints.byDistance {
            nearbyPointsWithinSetLimits = nearbyPointsInLineOfSight!.filter({$0.distanceFromCurrentLocation > newMin && $0.distanceFromCurrentLocation < newMax})
        } else {
            nearbyPointsWithinSetLimits = nearbyPointsInLineOfSight!.filter({$0.location.altitude > newMin && $0.location.altitude < newMax})
        }
        constraints.max = newMax
        constraints.range = newRange
        motionManager.restartMotionManager(motionHandler)
    }
    
    func removePointsFromScreen(pointsToRemove: [NearbyPoint]) {
        let shrunk = CGAffineTransformMakeScale(0.01, 0.01)
        for point in pointsToRemove {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.BeginFromCurrentState, animations: { point.label.transform = shrunk }, completion: { [weak self] finished in point.label.hidden = true } )
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionHandler(motionData: CMAccelerometerData!, error: NSError!) {
        if nearbyPointsInLineOfSight != nil && nearbyPointsManager != nil && locationManager != nil && locationManager.heading != nil {
            
            let zData = motionData.acceleration.z
            let zDelta = abs(zData - self.currentZ)
            self.currentZ = zData
            let heading = self.locationManager.heading.trueHeading
            let signedHeadingDelta = self.currentHeading! - heading
            let headingDelta = abs(signedHeadingDelta)
            self.currentHeading = heading
            
            // correct for heading error when phone is turned clockwise/counter-clockwise
            let yData = motionData.acceleration.y
            let correction = yData * HeadingConstants.YAxisCorrection
            let correctedHeading = locationManager.heading.trueHeading - correction;
            
            if let deviceHeading = returnHeadingBasedInProperCoordinateSystem(correctedHeading) {
                for nearbyPoint in nearbyPointsWithinSetLimits! {
                    let labelAngle = CGFloat(nearbyPoint.angleToHorizon)
                    let phoneAngle = CGFloat(90 * zData)
                    let yDifference = labelAngle - phoneAngle
                    let fieldOfVisionHalved = self.DeviceConstants.fieldOfVision/2.0

                    let yMultiplier = (yDifference+fieldOfVisionHalved)/(fieldOfVisionHalved*2)
                    
                    var fuzz = CGFloat(arc4random_uniform(3))
                    fuzz -= 1
                    
                    let yPosition = (self.DeviceConstants.PhoneWidth - yMultiplier * self.DeviceConstants.PhoneWidth) - (NearbyPointConstants.LabelFrameSize/2.0) + fuzz
                    var xDifference = CGFloat(deviceHeading - nearbyPoint.angleToCurrentLocation)
                    
                    // correct for cases such as when deviceHeading = 359 and angleToCurrentLocation = 1
                    let geographicalAngleOutsideFieldOfVision = 360.0-DeviceConstants.fieldOfVision
                    if xDifference < -geographicalAngleOutsideFieldOfVision {
                        xDifference += 360.0
                    } else if xDifference > geographicalAngleOutsideFieldOfVision {
                        xDifference -= 360.0
                    }
                    
                    var returningToScreen: Bool = false
                    
                    // if nearbyPoint is not within fieldOfVision * 2, hide it and continue!
                    if xDifference < -DeviceConstants.fieldOfVision - DeviceConstants.MarginForFieldOfVision || xDifference > DeviceConstants.fieldOfVision + DeviceConstants.MarginForFieldOfVision {
                        nearbyPoint.label.hidden = true
                        continue
                    } else {
                        if nearbyPoint.label.hidden == true {
                            returningToScreen = true
                        } else {
                            nearbyPoint.label.hidden = false
                        }
                    }
            
                    let xMultiplier = CGFloat((xDifference + fieldOfVisionHalved)/(fieldOfVisionHalved*2))
                    let xPosition = xMultiplier * self.DeviceConstants.PhoneHeight
                    
                    // if nearbyPoint.frame.center.x is about to be set to a point all the way across, reset it to a point on that side of the screen before animating it
                    if xPosition < 0.0 && nearbyPoint.label.center.x > DeviceConstants.PhoneHeight {
                        nearbyPoint.label.center = CGPoint(x: xPosition - 5.0, y: nearbyPoint.label.center.y)
                    } else if xPosition > DeviceConstants.PhoneHeight && nearbyPoint.label.center.x < 0.0 {
                        nearbyPoint.label.center = CGPoint(x: xPosition + 5.0, y: nearbyPoint.label.center.y)
                    }
                    
                    let animationDuration = 0.5
                    
                    if returningToScreen {
                        let shrunk = CGAffineTransformMakeScale(0.01, 0.01)
                        nearbyPoint.label.transform = shrunk
                        nearbyPoint.label.center = CGPoint(x: xPosition, y: yPosition)
                        nearbyPoint.label.hidden = false
                        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 20, options: UIViewAnimationOptions.CurveEaseInOut,animations: {
                            nearbyPoint.label.transform = CGAffineTransformIdentity
                            }, completion: nil )
                    } else {
                        
                        UIView.animateWithDuration(animationDuration,
                            delay: 0,
                            options: UIViewAnimationOptions.CurveEaseInOut
                                | UIViewAnimationOptions.AllowUserInteraction
                                | UIViewAnimationOptions.BeginFromCurrentState,
                            animations: {
                                nearbyPoint.label.center = CGPoint(x: xPosition, y: yPosition)
                                
                                var transform = CGFloat(signedHeadingDelta)/5.0
                                let transformFuzz = CGFloat(arc4random_uniform(UInt32(transform*400.0)))/1000.0 - 0.20*transform
                                transform += transformFuzz
                                nearbyPoint.label.transform = CGAffineTransformMakeRotation(transform)
                            },
                            completion: nil
                        )
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
        println("updating location")
        if manager != nil {
            if let location = locations.last as? CLLocation {
                if nearbyPointsManager != nil {
                    if let pointsManagerCurrentLocation = nearbyPointsManager.currentLocation {
                        if pointsManagerCurrentLocation.distanceFromLocation(location) > 1000 {
                            println("new location greater than 1000 meters")
							prepareForNewPointsAtLocation(location)
							nearbyPointsManager.getGeonamesJSONData()
                        }
                        // TEST
                            
                        else {
							println("less than 1000 meters")
							
							if didResignDuringRequest {
                                println("didResignDuringRequest")
                                showProgressIndicator()
								nearbyPointsManager.getGeonamesJSONData()
							} else {
                                println("superfluous location updates from phone's gps")
								if location.timestamp.timeIntervalSinceDate(pointsManagerCurrentLocation.timestamp) > 30.0 {
									removeCurrentNearbyPointsOnScreen()
									nearbyPointsManager.determineIfEachOfAllNearbyPointsIsInLineOfSight()
								}
							}
                        }

                        // TEST
                    } else {
                        println("first request")
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
    
    func removeCurrentNearbyPointsOnScreen() {
        if nearbyPointsInLineOfSight != nil {
            nearbyPointsInLineOfSight! += nearbyPointsToExpand
            nearbyPointsToExpand = [NearbyPoint]()
            for nearbyPoint in nearbyPointsInLineOfSight! {
                nearbyPoint.label.removeFromSuperview()
            }
            nearbyPointsInLineOfSight = [NearbyPoint]()
        }
        if nameLabel != nil {
            nameLabel.removeFromSuperview()
        }
    }
    
    func prepareForNewPointsAtLocation(location: CLLocation!) {
        
        showProgressIndicator()
        
        didCompleteFullRequest = false
        
        removeCurrentNearbyPointsOnScreen()
        
        nearbyPointsInLineOfSight = [NearbyPoint]()
        nearbyPointsManager.communicator?.startRowCount = 0
        nearbyPointsManager.recentlyRetrievedNearbyPoints = [NearbyPoint]()
        nearbyPointsManager.nearbyPoints = [NearbyPoint]()
        nearbyPointsManager.currentLocation = location
        
    }
    
    func prepareToDetermineLineOfSight() {
        let elevationDataManager = ElevationDataManager()
        elevationDataManager.dataDelegate = nearbyPointsManager
        elevationDataManager.currentLocationDelegate = nearbyPointsManager
        nearbyPointsManager.elevationDataManager = elevationDataManager
        
        // TEST
        
        elevationDataManager.gdalManager = TheGDALWrapper()
        elevationDataManager.gdalManager?.openGDALFile(ManagerConstants.ElevationDataFilename)
        
        // TEST
    }
    
    func fetchingFailedWithError(error: NSError) {
        
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        println("assembled points without altitude")
        
        if nearbyPointsManager != nil {
            prepareToDetermineLineOfSight()
            nearbyPointsManager.determineIfEachRecentlyRetrievedPointIsInLineOfSight()
        } else{
            println("we lost the nearbyPoints manager")
        }
        
        removeProgressIndicator()
    }
    
    func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint) {
        
        println("added nearbyPoint: \(nearbyPoint)")
        
        // TEST
        
        self.motionManager.stopAccelerometerUpdates()
        
        var newIndex = view.subviews.count
        for (index, subview) in enumerate(view.subviews as! [UIView]) {
            if nearbyPoint.label.layer.zPosition < subview.layer.zPosition {
                newIndex = index
                break
            }
        }
        self.view.insertSubview(nearbyPoint.label, atIndex: newIndex)
        
        self.nearbyPointsInLineOfSight?.append(nearbyPoint)
        
        if nearbyPoint.distanceFromCurrentLocation > distanceFarthestAway {
            distanceFarthestAway = nearbyPoint.distanceFromCurrentLocation
        }
        if nearbyPoint.location.altitude > tallest {
            tallest = nearbyPoint.location.altitude
        }
        
        if nearbyPoint.distanceFromCurrentLocation > constraints.min && nearbyPoint.distanceFromCurrentLocation < constraints.max {
            nearbyPointsWithinSetLimits?.append(nearbyPoint)
            println("nPWSL: \(nearbyPointsWithinSetLimits!)")
        }
        
        startMotionManagerUpdates()
        
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
        nameLabel = UITextView()
        nameLabel.text = nearbyPoint.name + "\n" + "elevation: \(nearbyPoint.location.altitudeInFeet.formatFeet()) feet" + "\n" + "distance: \(nearbyPoint.distanceFromCurrentLocationInMiles.formatMiles()) miles away" + "\n" + "location: \(nearbyPoint.location.formattedCoordinate)"
        nameLabel.backgroundColor = UIConstants.LabelBackgroundColor
        nameLabel.textColor = UIConstants.LabelColor
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.layer.cornerRadius = 10.0
        nameLabel.clipsToBounds = true
        nameLabel.font = UIConstants.LabelFont
        nameLabel.sizeToFit()
        let width = nameLabel.frame.width
        let height = nameLabel.frame.height
        let x = (nearbyPoint.label.frame.width - width)/2
        nameLabel.frame = CGRectMake(x, -height, width, height)
        nameLabel.layer.zPosition = 1000000
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
        
        let coordinateOfTap = gesture.locationInView(self.view)
        
        if nameLabel != nil && nameLabel!.superview != nil && nearbyPointCurrentlyDisplayed != nil {
            
            let labelOriginInMainView = CGPoint(x: nameLabel.superview!.frame.origin.x + nameLabel.frame.origin.x, y: nameLabel.superview!.frame.origin.y + nameLabel.frame.origin.y)
            let labelFrameInMainView = CGRect(origin: labelOriginInMainView, size: nameLabel.frame.size)
            
            if CGRectContainsPoint(labelFrameInMainView, coordinateOfTap) {
                openMapsApp()
            } else {
                toggleLimitType()
            }
        } else {
            toggleLimitType()
        }
    }
    
    func toggleLimitType() {
        let newMaxNotInUse = constraints.max
        let newRangeNotInUse = constraints.range
        let newMax = constraints.maxNotInUse
        let newRange = constraints.rangeNotInUse
        constraints = Constraints(range: newRange, max: newMax, rangeNotInUse: newRangeNotInUse, maxNotInUse: newMaxNotInUse, byDistance: !constraints.byDistance)
        filterPointsForConstraintToggle()
    }
    
    func filterPointsForConstraintToggle() {
        returnPointsToMotionHandler()
        if nearbyPointsInLineOfSight != nil {
            var pointsToRemove = [NearbyPoint]()
            if constraints.byDistance {
                pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.distanceFromCurrentLocation < self.constraints.min || $0.distanceFromCurrentLocation > self.constraints.max})
            } else {
                pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.location.altitude < self.constraints.min || $0.location.altitude > self.constraints.max})
            }
            removePointsFromScreen(pointsToRemove)
            if constraints.byDistance {
                nearbyPointsWithinSetLimits = nearbyPointsInLineOfSight!.filter({$0.distanceFromCurrentLocation > self.constraints.min && $0.distanceFromCurrentLocation < self.constraints.max})
            } else {
                nearbyPointsWithinSetLimits = nearbyPointsInLineOfSight!.filter({$0.location.altitude > self.constraints.min && $0.location.altitude < self.constraints.max})
            }
        }
    }
    
    func returnPointsToMotionHandler() {
        if nearbyPointsWithinSetLimits != nil {
            nearbyPointsWithinSetLimits! += nearbyPointsToExpand
            nearbyPointsToExpand = [NearbyPoint]()
            motionManager.restartMotionManager(motionHandler)
        }
    }
    
    func startMotionManagerUpdates() {
        motionManager.startAccelerometerUpdatesToQueue(motionQueue, withHandler: motionHandler)
    }
    
    func zoomIn(gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        var change = 1.0 - scale
        if scale < 1.0 {
            change *= VideoConstants.PreferredMaxVideoZoom
        }
        var newScale = zoomFactor - change
        switch gesture.state {
        case .Changed:
            // we're checking if the new zoom value is greater than 1 and also less than the developer-determined VideoConstants.PreferredMaxVideoZoom and the phone's camera's DeviceConstants.MaxVideoZoom
            if newScale >= 1.0 &&
            newScale <= VideoConstants.PreferredMaxVideoZoom &&
            newScale <= DeviceConstants.MaxVideoZoom {
                captureDevice?.lockForConfiguration(nil)
                captureDevice?.rampToVideoZoomFactor(newScale, withRate: 4.0)
                captureDevice?.unlockForConfiguration()
                
                DeviceConstants.fieldOfVision = DeviceConstants.ConstantFieldOfVision / newScale
                motionManager.restartMotionManager(motionHandler)
            }
        case .Ended:
            if newScale < 1.0 {
                zoomFactor = 1.0
            } else if newScale > VideoConstants.PreferredMaxVideoZoom {
                zoomFactor = VideoConstants.PreferredMaxVideoZoom
            } else {
                zoomFactor = newScale
            }
        default: break
        }
    }
    
    func expandPointsWithPan(gesture: UIPanGestureRecognizer) {
        
        let locationInView = gesture.locationInView(self.view)
        
        switch(gesture.state) {
        case .Began:
            
            var indexOfPointsToRemove = [Int]()
            locationOfPanGesture = locationInView
            
            if nearbyPointsWithinSetLimits != nil {
                
                for (index,nearbyPoint) in enumerate(nearbyPointsWithinSetLimits!) {
                    let labelButton = nearbyPoint.label
                    let labelButtonX = labelButton.frame.origin.x
                    let deltaX = labelButtonX - locationInView.x
                    if abs(deltaX) < 75.0 {
                        nearbyPointsToExpand.append(nearbyPoint)
                        indexOfPointsToRemove.append(index)
                    }
                }
                
                nearbyPointsToExpand.sort({$0.label.frame.origin.x < $1.label.frame.origin.x})
                
                for index in indexOfPointsToRemove.reverse() {
                    nearbyPointsWithinSetLimits?.removeAtIndex(index)
                }
                motionManager.restartMotionManager(motionHandler)
            }
            
        case .Changed:
            if !nearbyPointsToExpand.isEmpty {
                
                var numberOfPointsToExpand = nearbyPointsToExpand.count
                let xDelta = 2.0 * (locationInView.x - locationOfPanGesture.x)
                locationOfPanGesture = locationInView
                
                if numberOfPointsToExpand > 1 {
                    numberOfPointsToExpand -= 1
                    
                    for (index,pointToExpand) in enumerate(nearbyPointsToExpand) {
                        let signedIndex = numberOfPointsToExpand % 2 == 0 ? CGFloat(index) - CGFloat(numberOfPointsToExpand)/2.0 + 0.5 : CGFloat(index) - CGFloat(numberOfPointsToExpand)/2.0
                        let changeInOrigin = CGFloat(signedIndex)/CGFloat(numberOfPointsToExpand) * xDelta
                        UIView.animateWithDuration(0.25,
                            delay: 0,
                            options: UIViewAnimationOptions.CurveEaseInOut,
                            animations: {
                                pointToExpand.label.center = CGPoint(x: pointToExpand.label.center.x + changeInOrigin, y: pointToExpand.label.center.y)
                            },
                            completion: nil)
                    }
                }
            }
        default: break
        }
    }

    func openMapsApp() {
        
        var mapItems = [MKMapItem]()
        
        let pointOpen = nearbyPointCurrentlyDisplayed!
        let regionDistance: CLLocationDistance = 20000
        let regionSpan = MKCoordinateRegionMakeWithDistance(pointOpen.location.coordinate, regionDistance, regionDistance)
        println("\(regionSpan.span)")
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        
        let addressDictionary = [kABPersonAddressStreetKey as String:
            "coordinates: \(pointOpen.location.formattedCoordinate) \n" +
            "elevation: \(pointOpen.location.altitudeInFeet.formatFeet()) feet\n" +
            "distance: \(pointOpen.distanceFromCurrentLocationInMiles.formatMiles()) miles away"]
        let placemark = MKPlacemark(coordinate: pointOpen.location.coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pointOpen.name
        mapItems.append(mapItem)
        
        for point in nearbyPointsInLineOfSight! + nearbyPointsToExpand {
            if point === pointOpen {
                continue
            }
            let heading = returnHeadingBasedInProperCoordinateSystem(locationManager.heading.trueHeading)!
            var xDifference = CGFloat(heading - point.angleToCurrentLocation)
            
            // correct for cases such as when deviceHeading = 359 and angleToCurrentLocation = 1
            let geographicalAngleOutsideFieldOfVision = 360.0-DeviceConstants.fieldOfVision
            if xDifference < -geographicalAngleOutsideFieldOfVision {
                xDifference += 360.0
            } else if xDifference > geographicalAngleOutsideFieldOfVision {
                xDifference -= 360.0
            }
            if abs(xDifference) < DeviceConstants.fieldOfVision/2.0 + DeviceConstants.fieldOfVision/10.0 {
                
                let addressDictionary = [kABPersonAddressStreetKey as String:
                    "coordinates: \(point.location.formattedCoordinate) \n" +
                    "elevation: \(point.location.altitudeInFeet.formatFeet()) feet\n" +
                    "distance: \(pointOpen.distanceFromCurrentLocationInMiles.formatMiles()) miles away"]
                let placemark = MKPlacemark(coordinate: point.location.coordinate, addressDictionary: addressDictionary)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = point.name
                mapItems.append(mapItem)
            }
        }
        
        println("\(mapItems)")
        MKMapItem.openMapsWithItems(mapItems, launchOptions: options)
    }
    
    func removeProgressIndicator() {
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
    }
    
    func showProgressIndicator() {
        if activityIndicatorView == nil {
            var label = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
            label.text = UIConstants.ProgressIndicatorLabelText
            label.textColor = UIConstants.LabelColor
            activityIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
            activityIndicatorView!.center = CGPoint(x: DeviceConstants.PhoneHeight/2.0, y: DeviceConstants.PhoneWidth/2.0 - DeviceConstants.PhoneWidth/20.0)
            activityIndicatorView!.layer.cornerRadius = 15
            activityIndicatorView!.backgroundColor = UIConstants.LabelBackgroundColor
            
            var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            activityIndicatorView!.addSubview(activityIndicator)
            
            activityIndicatorView!.addSubview(label)
            view.addSubview(activityIndicatorView!)
        }
    }
    
    func resetVideoZoomValues(){
        DeviceConstants.fieldOfVision = DeviceConstants.ConstantFieldOfVision
        captureDevice?.lockForConfiguration(nil)
        captureDevice?.videoZoomFactor = 1.0
        captureDevice?.unlockForConfiguration()
    }

}

extension CMMotionManager {
    func restartMotionManager(handler: CMAccelerometerHandler) {
        self.stopAccelerometerUpdates()
        self.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: handler)
    }
}
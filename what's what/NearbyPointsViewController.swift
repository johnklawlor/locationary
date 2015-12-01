//
//  ViewController.swift
//  Locationary
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 John Lawlor. All rights reserved.
//
//  This file is part of Locationary.
//
//  Locationary is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Locationary is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit
import CoreLocation
import MapKit
import CoreMotion
import AVFoundation
import AddressBook

enum FilterType {
    case Distance
    case Altitude
}

struct Constraints {
    
    init(){
        max = 0
        maxNotInUse = 0
        filterType = .Distance
    }
    
    init(aMax: Int, aMaxNotInUse: Int, aFilterType: FilterType){
        max = aMax
        maxNotInUse = aMaxNotInUse
        filterType = aFilterType
    }
    
    var max: Int
    var min: Int{
        return max+numPossiblePointsOnScreen
    }
    var maxNotInUse: Int
    var numPossiblePointsOnScreen: Int = 25
    var filterType: FilterType
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
    
    var units = NSUserDefaults.standardUserDefaults().integerForKey("units_of_distance")
    
    var nearbyPointsManager: NearbyPointsManager!
    private let nearbyPointsQueue = dispatch_queue_create("nearbyPointsInLineOfSightQueue", nil)
    var queuedNearbyPointsInLineOfSight: [NearbyPoint]?
    var nearbyPointsInFieldOfVision: [NearbyPoint]?
    var nearbyPointsInLineOfSight: [NearbyPoint]? {
        get {
            var nearbyPoints: [NearbyPoint]?
            with(nearbyPointsQueue, f: { nearbyPoints = self.queuedNearbyPointsInLineOfSight })
            return nearbyPoints
        }
        set {
            with(nearbyPointsQueue, f: { self.queuedNearbyPointsInLineOfSight = newValue })
        }
    }
    var nearbyPointsInFieldOfVisionSorted: [NearbyPoint]? {
        if nearbyPointsInFieldOfVision != nil {
            switch(constraints.filterType){
            case .Distance:
                return nearbyPointsInFieldOfVision!.sort({$0.distanceFromCurrentLocation>$1.distanceFromCurrentLocation})
            case .Altitude:
                return nearbyPointsInFieldOfVision!.sort({$0.location.altitude>$1.location.altitude})
            }
        } else {
            return nil
        }
    }
    var distanceFarthestAway: CLLocationDistance = 0
    var tallest: CLLocationDistance = 0
    var constraints = Constraints()
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOnView:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        self.view.addGestureRecognizer(tapRecognizer)
        
        horizontalPanRecognizer = UIPanGestureRecognizer(target: self, action: "expandPointsWithPan:")
        horizontalPanRecognizer.delegate = self
        self.view.addGestureRecognizer(horizontalPanRecognizer)
        
        verticalPanRecognizer = UIPanGestureRecognizer(target: self, action: "changeDistanceOfPointsVisible:")
        verticalPanRecognizer.delegate = self
        self.view.addGestureRecognizer(verticalPanRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "returnStaticPointsToMotionHandler")
        longPressRecognizer.delegate = self
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // TEST
        
        captureManager?.addVideoInput()
        captureManager?.addVideoPreviewLayer()
        captureManager?.setPreviewLayer(self.view.layer.bounds, bounds: self.view.bounds)
        
        self.view.layer.addSublayer((captureManager?.previewLayer)!)
        
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
            
            returnStaticPointsToMotionHandler()
            locationOfOneFingerPanGesture = locationInView
            
        case .Changed:
            
            var newMax: Int
            
            let deltaY = (locationInView.y - locationOfOneFingerPanGesture.y)/3.5
            
            if abs(deltaY) > 1.0 {
                
                let tempNewMax = constraints.max + Int((deltaY))
                
                if tempNewMax < 0 {
                    newMax = 0
                } else if tempNewMax > nearbyPointsInFieldOfVision!.count-constraints.numPossiblePointsOnScreen {
                    newMax = nearbyPointsInFieldOfVision!.count-constraints.numPossiblePointsOnScreen
                } else {
                    newMax = tempNewMax
                }
                
                if nearbyPointsInFieldOfVision != nil {
                    removeAndFilterPointsForNewMax(newMax)
                }
                motionManager.restartMotionManager(motionHandler)
                locationOfOneFingerPanGesture = locationInView
            }
        case .Ended:
            print("\(nearbyPointsInFieldOfVision)")
        default:
            break
        }
        
    }
    
    func removePointsFromScreen(pointsToRemove: [NearbyPoint]) {
        let shrunk = CGAffineTransformMakeScale(0.01, 0.01)
        for point in pointsToRemove {
            UIView.animateWithDuration(0.5, delay: 0.0,
                options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.BeginFromCurrentState],
                animations: { point.label.transform = shrunk },
                completion: { finished in point.label.hidden = true } )
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionHandler(motionData: CMAccelerometerData?, error: NSError?) {
        if motionData != nil &&
            nearbyPointsInLineOfSight != nil &&
            nearbyPointsManager != nil &&
            locationManager != nil &&
            locationManager.heading != nil {
            
            let zData = motionData!.acceleration.z
            self.currentZ = zData
            let heading = self.locationManager.heading!.trueHeading
            let signedHeadingDelta = self.currentHeading! - heading
            self.currentHeading = heading
            
            // correct for heading error when phone is turned clockwise/counter-clockwise
            let yData = motionData!.acceleration.y
            let correction = yData * HeadingConstants.YAxisCorrection
            let correctedHeading = locationManager.heading!.trueHeading - correction;
            
            if let deviceHeading = returnHeadingBasedInProperCoordinateSystem(correctedHeading) {
                for nearbyPoint in nearbyPointsWithinSetLimits! {

                    // what's with this 4.0 here?
                    let labelAngle = CGFloat(nearbyPoint.angleToHorizon*1.0)
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
                    
                    // if nearbyPoint is not within fieldOfVision +/- margin, hide it and continue!
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
                            options: [UIViewAnimationOptions.CurveEaseInOut,
                                UIViewAnimationOptions.AllowUserInteraction,
                                UIViewAnimationOptions.BeginFromCurrentState],
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // what do you do when you guzzle down sweets?
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if var location = locations.last {
            if location.altitude == 0 {
                location = CLLocation(coordinate: location.coordinate, altitude: 600, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: location.timestamp)
            }
            if nearbyPointsManager != nil {
                if let pointsManagerCurrentLocation = nearbyPointsManager.currentLocation {
                    if pointsManagerCurrentLocation.distanceFromLocation(location) > 1000 {
                        prepareForNewPointsAtLocation(location)
                        nearbyPointsManager.getGeonamesJSONData()
                    }
                    // TEST
                        
                    else {
                        
                        if didResignDuringRequest {
                            showProgressIndicator()
                            nearbyPointsManager.getGeonamesJSONData()
                        } else {
                            if location.timestamp.timeIntervalSinceDate(pointsManagerCurrentLocation.timestamp) > 30.0 {
                                removeCurrentNearbyPointsOnScreen()
                                nearbyPointsManager.determineIfEachOfAllNearbyPointsIsInLineOfSight()
                            }
                        }
                    }

                    // TEST
                } else {
                    prepareForNewPointsAtLocation(location)
                    nearbyPointsManager.getGeonamesJSONData()
                }
            } else {
                // something went wrong--nearbyPointsManager is nil
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

        if nearbyPointsManager.elevationDataManager == nil {
            let elevationDataManager = ElevationDataManager()
            elevationDataManager.dataDelegate = nearbyPointsManager
            elevationDataManager.currentLocationDelegate = nearbyPointsManager
            nearbyPointsManager.elevationDataManager = elevationDataManager
            
            // TEST
            
            elevationDataManager.gdalManager = TheGDALWrapper()
            elevationDataManager.gdalManager?.openGDALFile(ManagerConstants.ElevationDataFilename)
        }
        // TEST
    }
    
    func fetchingFailedWithError(error: NSError) {
        
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        if nearbyPointsManager != nil {
            prepareToDetermineLineOfSight()
            nearbyPointsManager.determineIfEachRecentlyRetrievedPointIsInLineOfSight()
        } else{
            // we lost the nearbyPoints manager
        }
        
        removeProgressIndicator()
    }
    
    func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint) {
        
        print("\(nearbyPoint.name), \(nearbyPoint.location.altitude),\(nearbyPoint.distanceFromCurrentLocation), \(nearbyPoint.angleToHorizon)")
        
        // TEST
        
        self.motionManager.stopAccelerometerUpdates()
        
        var newIndex = view.subviews.count
        for (index, subview) in view.subviews.enumerate() {
            if nearbyPoint.label.layer.zPosition < subview.layer.zPosition {
                newIndex = index
                break
            }
        }
        self.view.insertSubview(nearbyPoint.label, atIndex: newIndex)
        
        self.nearbyPointsInLineOfSight?.append(nearbyPoint)
        
        startMotionManagerUpdates()
        
        // TEST
    }
    
    // TEST
    func didReceiveTapForNearbyPoint(nearbyPoint: NearbyPoint) {
        
        if let _ = nearbyPointCurrentlyDisplayed {

            var labelToRemove = nameLabel
            
            UIView.animateWithDuration(0.25,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {
                    self.nameLabel.alpha = 0.0
                },
                completion: { finished in
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
        
        let (elevationString, distanceString) = nearbyPoint.formattedDistanceStringsForUnits(units)
        
        nameLabel = UITextView()
        nameLabel.text = nearbyPoint.name + "\n" +
            "elevation: \(elevationString)" + "\n" +
            "distance: \(distanceString)" + "\n" +
            "location: \(nearbyPoint.location.formattedCoordinate)"
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
        
        let heading = returnHeadingBasedInProperCoordinateSystem(locationManager.heading?.trueHeading)!
        
        print(heading)
        
        let leftFieldOfView = heading - Double(DeviceConstants.fieldOfVision/2.0)
        let rightFieldOfView = heading + Double(DeviceConstants.fieldOfVision/2.0)
        
        print(leftFieldOfView)
        print(rightFieldOfView)
        
        if nearbyPointsWithinSetLimits != nil {
            removePointsFromScreen(nearbyPointsWithinSetLimits!)
        }
        nearbyPointsInFieldOfVision = []
        
        if nearbyPointsInLineOfSight != nil {
            for nearbyPoint in nearbyPointsInLineOfSight! {
                var angleToCurrentLocation = nearbyPoint.angleToCurrentLocation

                if angleToCurrentLocation < Double(DeviceConstants.fieldOfVision/2.0) && leftFieldOfView < 0 {
                    angleToCurrentLocation = angleToCurrentLocation + 360.0
                } else if angleToCurrentLocation + Double(DeviceConstants.fieldOfVision/2.0) > 360.0 && rightFieldOfView > 0 {
                    angleToCurrentLocation = angleToCurrentLocation - 360.0
                }

                if angleToCurrentLocation > leftFieldOfView && angleToCurrentLocation < rightFieldOfView {
                    nearbyPointsInFieldOfVision?.append(nearbyPoint)
                    removeAndFilterPointsForNewMax(0)
                }
            }
            /*
            if nearbyPointsInFieldOfVision?.isEmpty {
                notifyUserOfNoPointsInFieldOfVision()
            }
            */
        }
        
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
    
    func toggleFilterType() -> FilterType {
        switch(constraints.filterType){
        case .Distance: return .Altitude
        case .Altitude: return .Distance
        }
    }
    
    func toggleLimitType() {
        if nearbyPointsInLineOfSight?.count < constraints.numPossiblePointsOnScreen {
            return
        }
        returnStaticPointsToMotionHandler()
        let newMaxNotInUse = constraints.max
        let newMax = constraints.maxNotInUse
        constraints = Constraints(aMax: newMax, aMaxNotInUse: newMaxNotInUse, aFilterType: toggleFilterType())
        var pointsToRemove = [NearbyPoint]()
        switch(constraints.filterType){
        case .Distance:
            let farthest = nearbyPointsInFieldOfVisionSorted![constraints.max].distanceFromCurrentLocation
            let closest = nearbyPointsInFieldOfVisionSorted![constraints.min].distanceFromCurrentLocation
            pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.distanceFromCurrentLocation>farthest || $0.distanceFromCurrentLocation<closest})
        case .Altitude:
            let tallest = nearbyPointsInFieldOfVisionSorted![constraints.max].location.altitude
            let shortest = nearbyPointsInFieldOfVisionSorted![constraints.min].location.altitude
            pointsToRemove = nearbyPointsWithinSetLimits!.filter({$0.location.altitude>tallest || $0.location.altitude<shortest})
        }
        
        removePointsFromScreen(pointsToRemove)
        nearbyPointsWithinSetLimits = filterNearbyPointsInFieldOfVision()
    }
    
    func filterOutNearbyPointsNoLongerInSetLimits(newMax: Int) -> [NearbyPoint] {
        if newMax > constraints.max {
            return Array(nearbyPointsInFieldOfVisionSorted![constraints.max..<newMax])
        } else {
            return Array(nearbyPointsInFieldOfVisionSorted![newMax+constraints.numPossiblePointsOnScreen..<constraints.min])
        }
    }
    
    func filterNearbyPointsInFieldOfVision() -> [NearbyPoint] {
        switch(constraints.filterType){
        case .Distance:
            return Array(nearbyPointsInFieldOfVisionSorted![constraints.max..<constraints.min])
        case .Altitude:
            return Array(nearbyPointsInFieldOfVisionSorted![constraints.max..<constraints.min])
        }
    }
    
    func removeAndFilterPointsForNewMax(newMax: Int) {
        returnStaticPointsToMotionHandler()
        if nearbyPointsInFieldOfVision != nil {
            if nearbyPointsInFieldOfVision?.count < constraints.numPossiblePointsOnScreen {
                nearbyPointsWithinSetLimits = nearbyPointsInFieldOfVision
            } else {
                let pointsToRemove = filterOutNearbyPointsNoLongerInSetLimits(newMax)
                constraints.max = newMax
                removePointsFromScreen(pointsToRemove)
                nearbyPointsWithinSetLimits = filterNearbyPointsInFieldOfVision()
            }
        }
    }
    
    func returnStaticPointsToMotionHandler() {
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
        let newScale = zoomFactor - change
        switch gesture.state {
        case .Changed:
            // we're checking if the new zoom value is greater than 1 and also less than the developer-determined VideoConstants.PreferredMaxVideoZoom and the phone's camera's DeviceConstants.MaxVideoZoom
            if newScale >= 1.0 &&
            newScale <= VideoConstants.PreferredMaxVideoZoom &&
            newScale <= DeviceConstants.MaxVideoZoom {
                do {
                    try captureDevice?.lockForConfiguration()
                    captureDevice?.rampToVideoZoomFactor(newScale, withRate: 4.0)
                    captureDevice?.unlockForConfiguration()
                } catch {
                    print("Could not ramp to video zoom factor")
                }
                
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
                
                for (index,nearbyPoint) in nearbyPointsWithinSetLimits!.enumerate() {
                    let labelButton = nearbyPoint.label
                    let labelButtonX = labelButton.frame.origin.x
                    let deltaX = labelButtonX - locationInView.x
                    if abs(deltaX) < 75.0 {
                        nearbyPointsToExpand.append(nearbyPoint)
                        indexOfPointsToRemove.append(index)
                    }
                }
                
                nearbyPointsToExpand.sortInPlace({$0.label.frame.origin.x < $1.label.frame.origin.x})
                
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
                    
                    for (index,pointToExpand) in nearbyPointsToExpand.enumerate() {
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
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
 
        let (elevationString, distanceString) = pointOpen.formattedDistanceStringsForUnits(units)
        
        let addressDictionary = [kABPersonAddressStreetKey as String:
            "coordinates: \(pointOpen.location.formattedCoordinate) \n" +
            "elevation: \(elevationString)\n" +
            "distance: \(distanceString)"]
        let placemark = MKPlacemark(coordinate: pointOpen.location.coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pointOpen.name
        mapItems.append(mapItem)
        
        for point in nearbyPointsWithinSetLimits! + nearbyPointsToExpand {
            if point === pointOpen {
                continue
            }
            let heading = returnHeadingBasedInProperCoordinateSystem(locationManager.heading!.trueHeading)!
            var xDifference = CGFloat(heading - point.angleToCurrentLocation)
            
            // correct for cases such as when deviceHeading = 359 and angleToCurrentLocation = 1
            let geographicalAngleOutsideFieldOfVision = 360.0-DeviceConstants.fieldOfVision
            if xDifference < -geographicalAngleOutsideFieldOfVision {
                xDifference += 360.0
            } else if xDifference > geographicalAngleOutsideFieldOfVision {
                xDifference -= 360.0
            }
            if abs(xDifference) < DeviceConstants.fieldOfVision/2.0 + DeviceConstants.fieldOfVision/10.0 {
                
                let (elevationString, distanceString) = point.formattedDistanceStringsForUnits(units)
                let addressDictionary = [kABPersonAddressStreetKey as String:
                    "coordinates: \(point.location.formattedCoordinate) \n" +
                    "elevation: \(elevationString) \n" +
                    "distance: \(distanceString)"]
                let placemark = MKPlacemark(coordinate: point.location.coordinate, addressDictionary: addressDictionary)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = point.name
                mapItems.append(mapItem)
            }
        }
        
        MKMapItem.openMapsWithItems(mapItems, launchOptions: options)
    }
    
    func removeProgressIndicator() {
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
    }
    
    func showProgressIndicator() {
        if activityIndicatorView == nil {
            let label = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
            label.text = UIConstants.ProgressIndicatorLabelText
            label.textColor = UIConstants.LabelColor
            activityIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
            activityIndicatorView!.center = CGPoint(x: DeviceConstants.PhoneHeight/2.0, y: DeviceConstants.PhoneWidth/2.0 - DeviceConstants.PhoneWidth/20.0)
            activityIndicatorView!.layer.cornerRadius = 15
            activityIndicatorView!.backgroundColor = UIConstants.LabelBackgroundColor
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            activityIndicatorView!.addSubview(activityIndicator)
            
            activityIndicatorView!.addSubview(label)
            view.addSubview(activityIndicatorView!)
        }
    }
    
    func resetVideoZoomValues(){
        DeviceConstants.fieldOfVision = DeviceConstants.ConstantFieldOfVision
        do {
            try captureDevice?.lockForConfiguration()
            captureDevice?.videoZoomFactor = 1.0
            captureDevice?.unlockForConfiguration()
        } catch {
            print("Could not set video zoom factor")
        }
    }

}

extension CMMotionManager {
    func restartMotionManager(handler: CMAccelerometerHandler) {
        self.stopAccelerometerUpdates()
        self.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: handler)
    }
}
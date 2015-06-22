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

struct Constants {
    var fieldOfVision: CGFloat
    let ConstantFieldOfVision: CGFloat
    let MaxVideoZoom: CGFloat
    let PhoneWidth: CGFloat
    let PhoneHeight: CGFloat
    
    init(theFieldOfVision: Float, maxZoom: CGFloat, phoneWidth: CGFloat, phoneHeight: CGFloat) {
        fieldOfVision = CGFloat(theFieldOfVision)
        ConstantFieldOfVision = CGFloat(theFieldOfVision)
        MaxVideoZoom = maxZoom
        PhoneWidth = phoneWidth
        PhoneHeight = phoneHeight
    }
}

struct DistanceConstants {
    static let WithinRadius = CLLocationDistance(20000) // distance in meters
    static let NameLabelFontSize: CGFloat = 18.0
    static let NameLabelEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
}

struct VideoConstants {
    static let PreferredMaxVideoZoom: CGFloat = 4.0
}

class NearbyPointsViewController: UIViewController, CLLocationManagerDelegate, NearbyPointsManagerDelegate, LabelTapDelegate, UIGestureRecognizerDelegate {
    
    var motionQueue = NSOperationQueue.mainQueue()
    
    var captureManager: CaptureSessionManager?
    var captureDevice: AVCaptureDevice?
    var zoomFactor: CGFloat = 1.0
    
    var nearbyPointsManager: NearbyPointsManager!
    var nearbyPointsInLineOfSight: [NearbyPoint]?
    
    var currentHeading: CLLocationDirection! = 0
    var currentZ: CLLocationDirection! = 0
    
    var DeviceConstants: Constants!
    
    // TEST!
    var nameLabel: UITextView! = UITextView()
    var nearbyPointCurrentlyDisplayed: NearbyPoint?
    // TEST!
    
    var locationManager: CLLocationManager! {
        didSet {
//            println("location manager just set, view controller is \(self)")
            // TEST THIS!!!!!!!!!!!!
            locationManager.delegate = self
            // TEST THIS!!!!!!!!!!!!
            locationManager.distanceFilter = 100
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
    
    func openMapsApp(gesture: UITapGestureRecognizer) {
        
        if nameLabel != nil && nearbyPointCurrentlyDisplayed != nil {
            
            let coordinateOfTap = gesture.locationInView(self.view)
            
            let labelOriginInMainView = CGPoint(x: nameLabel.superview!.frame.origin.x + nameLabel.frame.origin.x, y: nameLabel.superview!.frame.origin.y + nameLabel.frame.origin.y)
            let labelFrameInMainView = CGRect(origin: labelOriginInMainView, size: nameLabel.frame.size)
            
            if CGRectContainsPoint(labelFrameInMainView, coordinateOfTap) {
                
                var latitute = nearbyPointCurrentlyDisplayed!.location.coordinate.latitude
                var longitute = nearbyPointCurrentlyDisplayed!.location.coordinate.longitude
                
                let regionDistance:CLLocationDistance = 10000
                var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                var options = [
                    MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
                ]
                var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                var mapItem = MKMapItem(placemark: placemark)
                mapItem.name = nearbyPointCurrentlyDisplayed!.name
                mapItem.openInMapsWithLaunchOptions(options)
            }
        }
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
            if newScale >= 1.0 && newScale <= VideoConstants.PreferredMaxVideoZoom && newScale <= DeviceConstants.MaxVideoZoom {
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
        
//        switch gesture.state {
//        case .Began:
//            let coordinateOfPinch = gesture.locationInView(self.view)
//        case .Changed:
//            fallthrough
//        case .Ended:
//            let scale = gesture.scale > 1.0 ? gesture.scale : -gesture.scale
//            println("scale: \(scale)")
//            
//            nearbyPointsInLineOfSight!.sort({$0.label.frame.origin.x < $1.label.frame.origin.x})
//            
//            let count = nearbyPointsInLineOfSight!.count/2
//            
//            for (index,point) in enumerate(nearbyPointsInLineOfSight!) {
//                var newIndex = index - count
//                if count % 2 == 0 && index >= 0 {
//                    newIndex += 1
//                }
//                point.label.frame.origin = CGPoint(x: point.label.frame.origin.x + scale * CGFloat(newIndex), y: point.label.frame.origin.y)
//            }
//            
//            gesture.scale = 1.0
//        default: break
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEST
        // can test these with view.gestures variable
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "zoomIn:")
        pinchRecognizer.delegate = self
        self.view.addGestureRecognizer(pinchRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "openMapsApp:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "didReceiveTapOnView:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        self.view.addGestureRecognizer(tapRecognizer)
        
        var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "didReceiveLongPressOnView:")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func motionHandler(motionData: CMAccelerometerData!, error: NSError!) {
        if nearbyPointsInLineOfSight != nil && nearbyPointsManager != nil && locationManager != nil && locationManager.heading != nil {
            
            let zData = motionData.acceleration.z
            let zDelta = abs(zData - self.currentZ)
            let heading = self.locationManager.heading.trueHeading
            let headingDelta = abs(heading - self.currentHeading!)
            self.currentHeading = heading
            
            let yData = motionData.acceleration.y
            let correction = yData * -67
            let correctedHeading = locationManager.heading.trueHeading - correction;
            
            if abs(zData - self.currentZ) > 0.01 {
                self.currentZ = zData
                if let deviceHeading = returnHeadingBasedInProperCoordinateSystem(correctedHeading) {
                    for nearbyPoint in nearbyPointsInLineOfSight! {
                        let labelAngle = CGFloat(nearbyPoint.angleToHorizon)
                        let phoneAngle = CGFloat(90 * zData)
                        let yDifference = labelAngle - phoneAngle
                        let fieldOfVisionHalved = CGFloat(self.DeviceConstants.fieldOfVision/2)

                        let yMultiplier = (yDifference+fieldOfVisionHalved)/(fieldOfVisionHalved*2)
                        
                        var fuzz = CGFloat(arc4random_uniform(3))
                        fuzz -= 1
                        
                        let yPosition = (self.DeviceConstants.PhoneWidth - yMultiplier * self.DeviceConstants.PhoneWidth) - (NearbyPointConstants.LabelFrameSize/2.0) + fuzz
                        var xDifference = CGFloat(deviceHeading - nearbyPoint.angleToCurrentLocation)
                        
                        if abs(xDifference) > 308 {
                            if xDifference < 0 {
                                xDifference = CGFloat(deviceHeading + (360.0 - nearbyPoint.angleToCurrentLocation))
                            } else {
                                xDifference = CGFloat((deviceHeading - 360.0) - nearbyPoint.angleToCurrentLocation)
                            }
                        }
                
                        let xMultiplier = CGFloat((xDifference + fieldOfVisionHalved)/(fieldOfVisionHalved*2))
                        let xPosition = xMultiplier * self.DeviceConstants.PhoneHeight
                        nearbyPoint.label.hidden = false
                        
                        let animationDuration = 0.5/(pow(zDelta+headingDelta, 0.5))
                        UIView.animateWithDuration(animationDuration,
                            delay: 0,
                            options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction,
                            animations: {
                                nearbyPoint.label.center = CGPoint(x: xPosition, y: yPosition)
                            },
                            completion: nil)
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
                            prepareForNewPointsAtLocation(location)
                            nearbyPointsManager.getGeonamesJSONData()
                        }
//                        // TEST
//                            
                        else {
                            removeCurrentNearbyPointsOnScreen()
                            nearbyPointsInLineOfSight = [NearbyPoint]()
                            nearbyPointsManager.determineIfEachOfAllNearbyPointsIsInLineOfSight()
                        }
//
//                        // TEST
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
    
    func removeCurrentNearbyPointsOnScreen() {
        if let nearbyPointsToRemoveFromView = nearbyPointsInLineOfSight {
            for nearbyPoint in nearbyPointsToRemoveFromView {
                nearbyPoint.label.removeFromSuperview()
            }
        }
        if nameLabel != nil {
            nameLabel.removeFromSuperview()
        }
    }
    
    func prepareForNewPointsAtLocation(location: CLLocation!) {
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
    }
    
    func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint) {
        
        println("added nearbyPoint: \(nearbyPoint)")
        
        // TEST
            
        self.nearbyPointsInLineOfSight?.append(nearbyPoint)
        
        self.view.addSubview(nearbyPoint.label)
        
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.startAccelerometerUpdatesToQueue(motionQueue, withHandler: motionHandler)
        
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
        nameLabel.backgroundColor = UIColor(red: 255, green: 250, blue: 217, alpha: 0.3)
        nameLabel.textContainerInset = DistanceConstants.NameLabelEdgeInsets
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.layer.cornerRadius = 10.0
        nameLabel.clipsToBounds = true
        let fontSize = DistanceConstants.NameLabelFontSize
        nameLabel.font = UIFont(name: "Helvetica Neue", size: fontSize)
        nameLabel.sizeToFit()
        let width = nameLabel.frame.width
        let height = nameLabel.frame.height
        let x = (nearbyPoint.label.frame.width - width)/2
        nameLabel.frame = CGRectMake(x, -height, width, height)
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
        motionManager.startAccelerometerUpdatesToQueue(motionQueue, withHandler: motionHandler)
    }
    
    func didReceiveLongPressOnView(gesture: UILongPressGestureRecognizer) {
        restartMotionManagerUpdates()
    }
}

extension CMMotionManager {
    func restartMotionManager(handler: CMAccelerometerHandler) {
        self.stopAccelerometerUpdates()
        self.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: handler)
    }
}
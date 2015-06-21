//
//  NearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import CoreLocation
import UIKit

protocol CurrentLocationDelegate: class {
    var currentLocation: CLLocation? { get }
}

protocol NearbyPointsManagerDelegate: class {
    func fetchingFailedWithError(error: NSError)
    func assembledNearbyPointsWithoutAltitude()
    func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint)
}

public struct ManagerConstants {
    static let Error_ReachedMaxConnectionAttempts = NSError(domain: "ManagerReachedMaximumAllowedConnectionAttempts", code: 1, userInfo: nil)
    static let Error_NearbyPointsIsNil = NSError(domain: "ManagerNearbyPointsIsNil-NothingToFetch", code: 2, userInfo: nil)
    static let ElevationDataFilename = "us_150max_bounding_compressed_tiled"

}

func with(queue: dispatch_queue_t, f: Void -> Void) {
    dispatch_sync(queue, f)
}

class NearbyPointsManager: NSObject, GeonamesCommunicatorDelegate, ElevationDataDelegate, CurrentLocationDelegate, GeonamesCommunicatorProvider {
    private let recentlyRetrievedNearbyPointsQueue = dispatch_queue_create("recentlyRetrievedNearbyPointsQueue", nil)
    
    var currentLocation: CLLocation? {
        didSet {
            communicator?.currentLocation = currentLocation
        }
    }
    var communicator: GeonamesCommunicator?
    var nearbyPointsJSON: String?
    var parser: GeonamesJSONParser!
    
    var nearbyPoints: [NearbyPoint]? = [NearbyPoint]()
    var recentlyRetrievedNearbyPoints = [NearbyPoint]()
    
    func appendToRecentlyRetrievedNearbyPoints(nearbyPointsToAppend: [NearbyPoint]) {
        recentlyRetrievedNearbyPoints += nearbyPointsToAppend
    }

    var prefetchError: NSError?
    var fetchingError: NSError?
    var parsingError: NSError?
    unowned var managerDelegate: NearbyPointsManagerDelegate
    
    var elevationDataManager: ElevationDataManager?
        
    var lowerDistanceLimit: CLLocationDistance! = 0
    var upperDistanceLimit: CLLocationDistance! = 100000
    
    init(delegate: NearbyPointsViewController) {
        managerDelegate = delegate
    }
    
    func getGeonamesJSONData() {
        println("trying to get geonames")
        if communicator?.requestAttempts <= 3 {
            println("getting geonames with communicator \(communicator)")
            communicator?.fetchJSONData()
        } else {
            managerDelegate.fetchingFailedWithError(ManagerConstants.Error_ReachedMaxConnectionAttempts)
        }
    }
    
    func fetchingNearbyPointsFailedWithError(error: NSError) {
        fetchingError = error
        // we should do something else here
        println("error fetching: \(error)")
    }
    
    func receivedNearbyPointsJSON(json: String) {
        println("received json")
        nearbyPointsJSON = json
        // if json is empty, attempt another request?
        var (nearbyPointsArray, error) = parser.buildAndReturnArrayFromJSON(json)
        
        // TEST
        if let actualError = error {
            if communicator != nil {
                communicator!.currentLocation = currentLocation
                getGeonamesJSONData()
                return
            }
        }
        if let receivedNearbyPointsArray = nearbyPointsArray as? [NearbyPoint] {
            with(recentlyRetrievedNearbyPointsQueue, {
                self.recentlyRetrievedNearbyPoints += receivedNearbyPointsArray
            })
            managerDelegate.assembledNearbyPointsWithoutAltitude()
        }
        else {
            println("inform delegate that there are no points around user!")
        }
    }
    
    func determineIfEachRecentlyRetrievedPointIsInLineOfSight() {
//        println("recentlyRetrievedNearbyPoints count: \(recentlyRetrievedNearbyPoints.count)")
        with(recentlyRetrievedNearbyPointsQueue, {
            if !self.recentlyRetrievedNearbyPoints.isEmpty {
                self.determineIfEachPointIsInLineOfSight(&self.recentlyRetrievedNearbyPoints)
                
                println("nearbyPoints array: \(self.nearbyPoints!.count)")
                self.nearbyPoints! += self.recentlyRetrievedNearbyPoints
                self.recentlyRetrievedNearbyPoints = [NearbyPoint]()
                println("nearbyPoints count: \(self.nearbyPoints!.count)")
            }
        })
    }
    
    func determineIfEachOfAllNearbyPointsIsInLineOfSight() {
        if nearbyPoints != nil {
            determineIfEachPointIsInLineOfSight(&nearbyPoints!)
        } else {
            println("trying to determineIfEachPointIsInLineOfSight. nearbyPoints is nil.")
            prefetchError = ManagerConstants.Error_NearbyPointsIsNil
        }
    }
    
    func determineIfEachPointIsInLineOfSight(inout someNearbyPoints: [NearbyPoint]) {
        println("nearbyPoints count when fetching line of sight data is \(someNearbyPoints.count)")
        
        for nearbyPoint in someNearbyPoints {
            calculateDistanceFromCurrentLocation(nearbyPoint)
            self.elevationDataManager!.getElevationForPoint(nearbyPoint)
        }
    }
    
    func processElevationProfileDataForPoint(nearbyPoint: NearbyPoint, elevationData: ElevationData) {
        
        if nearbyPoint.name == "Smarts Mountain" {
            println("elevationData: \(elevationData)")
        }
        
        if elevationData.elevation == 32678 {
            // should we try to get its elevation again? should we remove it from the nearbyPoints array?
            // should we make a request to Geonames to get the elevation of the point and simply display it?
            for (index, theNearbyPointToDelete) in enumerate(nearbyPoints!) {
                if nearbyPoint == theNearbyPointToDelete {
                    nearbyPoints!.removeAtIndex(index)
                    break
                }
            }
        } else if elevationData.inLineOfSight == true {
            
            calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
            
            println("elevation: \(elevationData.elevation)")
            println("angleToHorizon: \(elevationData.angleToHorizon)")
            
            updateElevationAndAngleToHorizonForPoint(nearbyPoint, elevation: elevationData.elevation, angleToHorizon: elevationData.angleToHorizon)
            
            let labelFrame = CGRectMake(50, 100, NearbyPointConstants.LabelFrameSize, NearbyPointConstants.LabelFrameSize)
            let labelButton = UIButton()
            labelButton.frame = labelFrame
            nearbyPoint.label = labelButton
            
            // TEST

            let rectangleSize = (1.0/pow(nearbyPoint.distanceFromCurrentLocation/1000.0, 0.5))*10.0 + 22
            var theButtonImage = UIImage(named: "overlaygraphic.png")
            let rectangle = CGRect(x: 0, y: 0, width: rectangleSize, height: rectangleSize)
            UIGraphicsBeginImageContextWithOptions(rectangle.size, false, 0.0);
            theButtonImage?.drawInRect(rectangle)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let buttonImage = newImage
            
            nearbyPoint.label.setImage(theButtonImage, forState: UIControlState.Normal)
            
            let firstInitialLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: labelFrame.size))
            let firstCharacterIndex = advance(nearbyPoint.name.startIndex,0)
            let firstLetterOfNearbyPointName = String(nearbyPoint.name[firstCharacterIndex])
            firstInitialLabel.text = firstLetterOfNearbyPointName
            let fontSize = CGFloat(rectangleSize/2.0)
            firstInitialLabel.font = UIFont(name: "Helvetica Neue", size: fontSize)
            firstInitialLabel.textAlignment = .Center
            firstInitialLabel.textColor = UIColor.whiteColor()
            
            nearbyPoint.label.addSubview(firstInitialLabel)
            
            // TEST
            
            let viewController = managerDelegate as! NearbyPointsViewController
            nearbyPoint.labelTapDelegate = viewController
            
            managerDelegate.foundNearbyPointInLineOfSight(nearbyPoint)
        }
    }
    
    func updateElevationAndAngleToHorizonForPoint(nearbyPoint: NearbyPoint, elevation: Double, angleToHorizon: Double) {
        nearbyPoint.location = CLLocation(coordinate: nearbyPoint.location.coordinate, altitude: elevation, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        nearbyPoint.angleToHorizon = angleToHorizon
    }
    
    func calculateDistanceFromCurrentLocation(nearbyPoint: NearbyPoint) {
        nearbyPoint.distanceFromCurrentLocation = currentLocation!.distanceFromLocation(nearbyPoint.location)
    }
    
    func calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint: NearbyPoint) {
        let y = CLLocation(coordinate: CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: nearbyPoint.location.coordinate.longitude), altitude: nearbyPoint.location.altitude, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
        let dy = y.distanceFromLocation(nearbyPoint.location)
        // nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude ? : -(y.distanceFromLocation(nearbyPoint.location))
        
        if nearbyPoint.location.coordinate.longitude < currentLocation!.coordinate.longitude {
            if nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude {
                nearbyPoint.angleToCurrentLocation = 180.0 - asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180.0/M_PI)
            } else {
                nearbyPoint.angleToCurrentLocation = 180.0 + asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180.0/M_PI)
            }
        } else {
            if nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude {
                nearbyPoint.angleToCurrentLocation = asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI)
            } else {
                nearbyPoint.angleToCurrentLocation = 360.0 - asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180.0/M_PI)
            }
        }
    }
    
    func calculateAngleToHorizon(nearbyPoint: NearbyPoint) {
        if currentLocation != nil {
            let distanceAway = nearbyPoint.distanceFromCurrentLocation
            let heightToSubtract = ((2/3)*pow(distanceAway/1000*1.60934,2)) * 0.304
            let nearbyPointAltitude = nearbyPoint.location.altitude
            let height = nearbyPointAltitude - currentLocation!.altitude - heightToSubtract
            let angle = atan(height/distanceAway)*(360.0/M_PI)
            
            nearbyPoint.angleToHorizon = angle
        }
    }
    
}
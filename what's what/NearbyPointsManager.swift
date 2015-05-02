//
//  NearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import CoreLocation
import UIKit

protocol NearbyPointsManagerDelegate: class {
    func fetchingFailedWithError(error: NSError)
    func assembledNearbyPointsWithoutAltitude()
    func retrievedNearbyPointInLineOfSight(nearbyPoint: NearbyPoint)
    func updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoints: [NearbyPoint])
}

public struct ManagerConstants {
    static let Error_ReachedMaxConnectionAttempts = NSError(domain: "ManagerReachedMaximumAllowedConnectionAttempts", code: 1, userInfo: nil)
    static let Error_NearbyPointsIsNil = NSError(domain: "ManagerNearbyPointsIsNil-NothingToFetch", code: 2, userInfo: nil)

}

class NearbyPointsManager: NSObject, GeonamesCommunicatorDelegate, ElevationManagerDelegate, CurrentLocationDelegate {
    var currentLocation: CLLocation? {
        didSet {
            communicator?.currentLocation = currentLocation
        }
    }
    var communicator: GeonamesCommunicator?
    var nearbyPointsJSON: String?
    var parser: GeonamesJSONParser!
    var nearbyPoints: [NearbyPoint]?
    var nearbyPointsInLineOfSight: [NearbyPoint]?
    var nearbyPointsWithAltitude: [NearbyPoint]?

    var prefetchError: NSError?
    var fetchingError: NSError?
    var parsingError: NSError?
    unowned var managerDelegate: NearbyPointsManagerDelegate
    
    var lowerDistanceLimit: CLLocationDistance! = 0
    var upperDistanceLimit: CLLocationDistance! = 100000
    
    init(delegate: NearbyPointsViewController) {
        managerDelegate = delegate
    }
    
    func getGeonamesJSONData() {
        println("trying to get geonames")
        if communicator?.requestAttempts <= 3 {
            println("getting geonames")
            communicator?.fetchGeonamesJSONData()
        } else {
            managerDelegate.fetchingFailedWithError(ManagerConstants.Error_ReachedMaxConnectionAttempts)
        }
    }
    
    func fetchingNearbyPointsFailedWithError(error: NSError) {
        fetchingError = error
        // we should do something else here
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
            
            // TEST
            nearbyPoints = receivedNearbyPointsArray
            // TEST
            
            managerDelegate.assembledNearbyPointsWithoutAltitude()
        }
    }
    
    func determineIfEachPointIsInLineOfSight() {
        println("nearbyPoints when fetching line of sight data is \(nearbyPoints)")
        if nearbyPoints != nil {
            nearbyPointsWithAltitude = [NearbyPoint]()
            for nearbyPoint in nearbyPoints! {
                getElevationProfileDataForPoint(nearbyPoint)
            }
        } else {
            println("trying to determineIfEachPointIsInLineOfSight. nearbyPoints is nil.")
            prefetchError = ManagerConstants.Error_NearbyPointsIsNil
        }
    }
    
    func getElevationProfileDataForPoint(nearbyPoint: NearbyPoint) {
        nearbyPoint.elevationManagerDelegate = self
        nearbyPoint.currentLocationDelegate = self
        nearbyPoint.googleMapsCommunicator = GoogleMapsCommunicator()
        
        if let viewController = managerDelegate as? NearbyPointsViewController {
            nearbyPoint.labelTapDelegate = viewController
        }
        
        if self.parser != nil {
            nearbyPoint.parser = self.parser
        } else {
            println("trying to determineLineOfSight in NearbyPointsManager and nearbyPointManagerParser is gone")
        }
        
        // dispatch_async
        nearbyPoint.getElevationProfileData()
        // dispatch_async
    }
    
    func parsingElevationProfileFailedWithError(error: NSError) {
        parsingError = error
    }
    
    func currentLocationCanViewNearbyPoint(nearbyPoint: NearbyPoint) {
        nearbyPointsWithAltitude?.append(nearbyPoint)
        managerDelegate.retrievedNearbyPointInLineOfSight(nearbyPoint)
    }

    func currentLocationCANNOTViewNearbyPoint(nearbyPoint: NearbyPoint) {
        nearbyPointsWithAltitude?.append(nearbyPoint)
    }
    
//    func getAltitudeJSONDataForEachPoint() {
//        println("nearbyPoints when fetching altitudes is \(nearbyPoints)")
//        if nearbyPoints != nil && !(nearbyPoints!.isEmpty) {
//            for nearbyPoint in nearbyPoints! {
//                nearbyPoint.altitudeManagerDelegate = self
//                nearbyPoint.altitudeCommunicator = AltitudeCommunicator()
//                
//                if let viewController = managerDelegate as? NearbyPointsViewController {
//                    nearbyPoint.labelTapDelegate = viewController
//                }
//                
//                if self.parser != nil {
//                    if nearbyPoint.parser == nil {
//                        println("nearbyPoint's parser is gone")
//                        nearbyPoint.parser = self.parser
//                    }
//                } else {
//                    println("nearbyPointManagerParser is gone")
//                    // should we create a new parser here? is this parser a singleton like cmmotion is?
//                }
//                
//                nearbyPoint.getAltitudeJSONData()
//            }
//        } else {
//            // should we make another request to get nearby points?
//        }
//    }
    
    // should we try to request altitude data from another web service?
    func gettingAltitudeFailedWithError(error: NSError) {
        fetchingError = error
    }
    
    func parsingAltitudeFailedWithError(error: NSError) {
        parsingError = error
    }
    
//    func successfullyRetrievedAltitude(nearbyPoint: NearbyPoint) {
//        println("got altitude data")
//        if currentLocation != nil {
//            calculateDistanceFromCurrentLocation(nearbyPoint)
//            calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
//            calculateAngleToHorizon(nearbyPoint)
//            
//            // TEST THIS!
//            nearbyPoint.label = UIButton(frame: CGRectMake(375.0/2, 667.0/2, 17, 16))
//            nearbyPoint.label.setBackgroundImage(UIImage(named: "overlaygraphic.png"), forState: UIControlState.Normal)
//            nearbyPoint.label.hidden = true
//            // TEST THIS!
//            
//            nearbyPointsWithAltitude?.append(nearbyPoint)
//
//            managerDelegate.retrievedNearbyPointWithAltitudeAndUpdatedDistance(nearbyPoint)
//            
////            if nearbyPoint.distanceFromCurrentLocation > lowerDistanceLimit &&
////                nearbyPoint.distanceFromCurrentLocation < upperDistanceLimit {
////            }
//        }
//    }
    
    func updateDistanceOfNearbyPointsWithAltitude() {
        if nearbyPointsWithAltitude != nil {
            for nearbyPoint in nearbyPointsWithAltitude! {
                calculateDistanceFromCurrentLocation(nearbyPoint)
                calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
                calculateAngleToHorizon(nearbyPoint)
            }
            managerDelegate.updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPointsWithAltitude!)
        }
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
                nearbyPoint.angleToCurrentLocation = 180.0 - asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI)
            } else {
                nearbyPoint.angleToCurrentLocation = 180 + asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI)
            }
        } else {
            if nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude {
                nearbyPoint.angleToCurrentLocation = asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI)
            } else {
                nearbyPoint.angleToCurrentLocation = 360 - asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI)
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
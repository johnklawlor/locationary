//
//  NearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import CoreLocation
import UIKit

protocol NearbyPointsManagerDelegate {
    func fetchingFailedWithError(error: NSError)
    func assembledNearbyPointsWithoutAltitude()
    func retrievedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoint: NearbyPoint)
    func updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoints: [NearbyPoint])
}

public struct ManagerConstants {
    static let Error_ReachedMaxConnectionAttempts = NSError(domain: "ManagerReachedMaximumAllowedConnectionAttempts", code: 1, userInfo: nil)
}

class NearbyPointsManager: GeonamesCommunicatorDelegate, AltitudeManagerDelegate {
    var currentLocation: CLLocation? {
        didSet {
            communicator?.currentLocation = currentLocation
        }
    }
    var communicator: GeonamesCommunicator?
    var nearbyPointsJSON: String?
    var parser: GeoNamesJSONParser!
    var nearbyPoints: [NearbyPoint]?
    var nearbyPointsWithAltitude: [NearbyPoint]?

    var fetchingError: NSError?
    var parsingAltitudeError: NSError?
    var managerDelegate: NearbyPointsManagerDelegate?
    
    var lowerDistanceLimit: CLLocationDistance! = 0
    var upperDistanceLimit: CLLocationDistance! = 100000
    
    init() {
    }
    
    func getGeonamesJSONData() {
        println("trying to get geonames")
        if communicator?.requestAttempts <= 3 {
            println("getting geonames")
            communicator?.fetchGeonamesJSONData()
        } else {
            managerDelegate?.fetchingFailedWithError(ManagerConstants.Error_ReachedMaxConnectionAttempts)
        }
    }
    
    func fetchingNearbyPointsFailedWithError(error: NSError) {
        fetchingError = error
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
        if let castNearbyPointsArray = nearbyPointsArray as? [NearbyPoint] {
            
            // TEST
            nearbyPoints = castNearbyPointsArray
            // TEST
            
            managerDelegate?.assembledNearbyPointsWithoutAltitude()
        }
    }
    
    func getAltitudeJSONDataForEachPoint() {
        println("nearbyPoints when fetching altitudes is \(nearbyPoints)")
        if nearbyPoints != nil && !(nearbyPoints!.isEmpty) {
            nearbyPointsWithAltitude = [NearbyPoint]()
            for nearbyPoint in nearbyPoints! {
                nearbyPoint.managerDelegate = self
                var altitudeCommunicator = AltitudeCommunicator()
                nearbyPoint.altitudeCommunicator = altitudeCommunicator
                
                // TEST
                
                if let viewController = managerDelegate as? NearbyPointsViewController {
                    nearbyPoint.labelTapDelegate = viewController
                }
                
                // TEST
                
                if self.parser != nil {
                    nearbyPoint.parser = self.parser
                } else {
                    println("nearbyPointManagerParser is gone")
                }
                // TEST
                
                
                nearbyPoint.getAltitudeJSONData()
            }
        }
    }
    
    // should we try to request altitude data from another web service?
    func gettingAltitudeFailedWithError(error: NSError) {
        fetchingError = error
    }
    
    func parsingAltitudeFailedWithError(error: NSError) {
        parsingAltitudeError = error
    }
    
    func successfullyRetrievedAltitude(nearbyPoint: NearbyPoint) {
        println("got altitude data")
        if currentLocation != nil {
            calculateDistanceFromCurrentLocation(nearbyPoint)
            calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
            calculateAngleToHorizon(nearbyPoint)
            
            // TEST THIS!
            nearbyPoint.label = UIImageView(image: UIImage(named: "overlaygraphic.png"))
            nearbyPoint.label.hidden = true
            nearbyPoint.label.frame = CGRectMake(375.0/2, 667.0/2, 17, 16)
            // TEST THIS!
            
            nearbyPointsWithAltitude?.append(nearbyPoint)
            if nearbyPoint.distanceFromCurrentLocation > lowerDistanceLimit &&
                nearbyPoint.distanceFromCurrentLocation < upperDistanceLimit {
                managerDelegate?.retrievedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoint)
            }
        }
    }
    
    func updateDistanceOfNearbyPointsWithAltitude() {
        if nearbyPointsWithAltitude != nil {
            for nearbyPoint in nearbyPointsWithAltitude! {
                calculateDistanceFromCurrentLocation(nearbyPoint)
                calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
                calculateAngleToHorizon(nearbyPoint)
            }
            managerDelegate?.updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPointsWithAltitude!)
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
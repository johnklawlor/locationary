//
//  NearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import CoreLocation

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
        if communicator?.requestAttempts <= 3 {
            communicator?.fetchGeonamesJSONData()
        } else {
            managerDelegate?.fetchingFailedWithError(ManagerConstants.Error_ReachedMaxConnectionAttempts)
        }
    }
    
    func fetchingNearbyPointsFailedWithError(error: NSError) {
        fetchingError = error
    }
    
    func receivedNearbyPointsJSON(json: String) {
        nearbyPointsJSON = json
        // if json is empty, attempt another request?
        var (nearbyPoints, error) = parser.buildAndReturnArrayFromJSON(json)
        
        if error != nil {
            if communicator != nil {
                communicator!.currentLocation = currentLocation
                getGeonamesJSONData()
                return
            }
        }
        if nearbyPoints != nil {
            managerDelegate?.assembledNearbyPointsWithoutAltitude()
        }
    }
    
    func getAltitudeJSONDataForEachPoint() {
        if nearbyPoints != nil && !(nearbyPoints!.isEmpty) {
            nearbyPointsWithAltitude = [NearbyPoint]()
            for nearbyPoint in nearbyPoints! {
                nearbyPoint.managerDelegate = self
                nearbyPoint.altitudeCommunicator = AltitudeCommunicator()
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
        if currentLocation != nil {
            calculateDistanceFromCurrentLocation(nearbyPoint)
            calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
            calculateAngleToHorizon(nearbyPoint)
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
        let dy = nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude ? y.distanceFromLocation(nearbyPoint.location) : -(y.distanceFromLocation(nearbyPoint.location))
        let theta = (dy < 0) ? 360 + asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI) : asin(dy/nearbyPoint.distanceFromCurrentLocation)*(180/M_PI)
        nearbyPoint.angleToCurrentLocation = theta
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
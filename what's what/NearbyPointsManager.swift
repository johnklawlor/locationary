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
        calculateDistanceFromCurrentLocation(nearbyPoint)
        nearbyPointsWithAltitude?.append(nearbyPoint)
        if nearbyPoint.distanceFromCurrentLocation > lowerDistanceLimit &&
            nearbyPoint.distanceFromCurrentLocation < upperDistanceLimit {
            managerDelegate?.retrievedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoint)
        }
    }
    
    func calculateDistanceFromCurrentLocation(nearbyPoint: NearbyPoint) {
        if currentLocation != nil {
            nearbyPoint.distanceFromCurrentLocation = currentLocation!.distanceFromLocation(nearbyPoint.location)
        }
    }
}
//
//  NearbyPoint.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

func == (lhs: NearbyPoint, rhs: NearbyPoint) -> Bool {
    if lhs.location == rhs.location {
        if lhs.name == lhs.name {
            return true
        }
    }
    return false
}

protocol AltitudeManagerDelegate: class {
    func gettingAltitudeFailedWithError(error: NSError)
    func parsingAltitudeFailedWithError(error: NSError)
    func successfullyRetrievedAltitude(nearbyPoint: NearbyPoint)
}

class NearbyPoint: AltitudeCommunicatorDelegate, Equatable, Printable {
    
    var description: String {
        return "name: \(name), \n location: \(location)"
    }
    
    init(aName: String, aLocation: CLLocation!) {
        name = aName
        location = aLocation
        parser = GeoNamesJSONParser()
    }
    
    var name: String!
    var location: CLLocation!
    var distanceFromCurrentLocation: CLLocationDistance!
    
    var altitudeCommunicator: AltitudeCommunicator?
    var fetchingError: NSError?
    var altitudeJSONString: String?
    
    var parser: GeoNamesJSONParser!

    weak var managerDelegate: AltitudeManagerDelegate?
    
    func getAltitudeJSONData() {
        if altitudeCommunicator != nil {
            altitudeCommunicator!.altitudeCommunicatorDelegate = self
            altitudeCommunicator!.locationOfAltitudeToFetch = location
            altitudeCommunicator!.fetchAltitudeJSONData()
        }
    }
    
    func fetchingAltitudeFailedWithError(error: NSError) {
        fetchingError = error
        managerDelegate?.gettingAltitudeFailedWithError(error)
    }
    
    func receivedAltitudeJSON(json: String) {
        altitudeJSONString = json
        let (altitude, error) = parser.buildAndReturnArrayFromJSON(json)
        
        if let parserError = error {
            managerDelegate?.parsingAltitudeFailedWithError(parserError)
        }
        
        if let altitudeArray = altitude as? [NSInteger] {
            if let altitudeValue = altitudeArray.first {
                location = CLLocation(coordinate: location.coordinate, altitude: Double(altitudeValue), horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, timestamp: location.timestamp)
                managerDelegate?.successfullyRetrievedAltitude(self)
            }
        }
    }
}
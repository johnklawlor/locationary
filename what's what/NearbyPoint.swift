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

protocol LabelTapDelegate {
    func didReceiveTapForNearbyPoint(nearbyPoint: NearbyPoint)
}

protocol CurrentLocationDelegate {
    var currentLocation: CLLocation? { get }
}

struct NearbyPointConstants {
    static let Error_GoogleMapsCommunicatorNil = NSError(domain: "GoogleMapsCommunicatorIsNil-CannotFetch", code: 1, userInfo: nil)
    static let Error_AltitudeCommunicatorNil = NSError(domain: "AltitudeCommunicatorIsNil-CannotFetch", code: 2, userInfo: nil)
    static let Error_NoCurrentLocation = NSError(domain: "NoCurrentLocation-CannotFetchElevationProfile", code: 3, userInfo: nil)
    static let Error_NoNearbyPointLocation = NSError(domain: "NoNearbyPointLocation-CannotFetchElevationProfile", code: 4, userInfo: nil)
}

class NearbyPoint: NSObject, AltitudeCommunicatorDelegate, GoogleMapsCommunicatorDelegate, Equatable, Printable {
    
    init(aName: String, aLocation: CLLocation!) {
        name = aName
        location = aLocation
        parser = GeonamesJSONParser()
    }
    
    let name: String!
    var location: CLLocation!
    var distanceFromCurrentLocation: CLLocationDistance!
    var angleToCurrentLocation: Double!
    var angleToHorizon: Double!
    
    // TEST
    var labelTapDelegate: LabelTapDelegate?
    // TEST
    
    // TEST THIS!
    var label: UIButton! {
        didSet {
            label.addTarget(self, action: "showName:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    // TEST THIS!
    
    var googleMapsCommunicator: GoogleMapsCommunicator?
    var altitudeCommunicator: AltitudeCommunicator?
    var prefetchError: NSError?
    var fetchingError: NSError?
    var altitudeJSONString: String?
    
    var currentLocationDelegate: CurrentLocationDelegate?
    
    var parser: GeonamesJSONParser!

    weak var managerDelegate: AltitudeManagerDelegate?
    
    func getAltitudeJSONData() {
        if let communicator = altitudeCommunicator {
            communicator.altitudeCommunicatorDelegate = self
            communicator.locationOfAltitudeToFetch = location
            communicator.fetchAltitudeJSONData()
        } else {
            // TEST
            prefetchError = NearbyPointConstants.Error_AltitudeCommunicatorNil
            // TEST
        }
    }
    
    func determineIfInLineOfSight() {
        if let communicator = googleMapsCommunicator {
            if let currentLocation = currentLocationDelegate?.currentLocation {
                if location != nil {
                    communicator.currentLocation = currentLocation
                    communicator.locationOfNearbyPoint = location
                    communicator.googleMapsCommunicatorDelegate = self
                    communicator.fetchElevationProfileJSONData()
                }
                else {
                    prefetchError = NearbyPointConstants.Error_NoNearbyPointLocation
                    println("location is nil. cannot fetch.")
                }
            } else {
                println("currentLocationDelegate is nil. cannot fetch.")
                prefetchError = NearbyPointConstants.Error_NoCurrentLocation
            }
            
        } else {
            println("googleMapsCommunicator is nil. cannot fetch.")
            prefetchError = NearbyPointConstants.Error_GoogleMapsCommunicatorNil
        }
    }
    
    func fetchingElevationProfileFailedWithError(error: NSError) {
        println("fetchingElevationProfileFailedWithError: \(error)")
    }
    
    func receivedElevationProfileJSON(json: String) {
        println("received elevation profile JSON data")
    }
    
    func fetchingAltitudeFailedWithError(error: NSError) {
        println("fetchingAltitudeFailedWithError: \(error)")
        fetchingError = error
        managerDelegate?.gettingAltitudeFailedWithError(error)
    }
    
    func receivedAltitudeJSON(json: String) {
        println("got altitude data")
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
    
    // TEST
    func showName(sender: UIButton!) {
        labelTapDelegate?.didReceiveTapForNearbyPoint(self)
    }
    // TEST
}
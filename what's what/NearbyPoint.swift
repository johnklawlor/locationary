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

protocol ElevationManagerDelegate: class {
    func parsingElevationProfileFailedWithError(error: NSError)
    func currentLocationCanViewNearbyPoint(nearbyPoint: NearbyPoint)
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
    static let Error_JSONIsNil = NSError(domain: "ElevationProfileJSONStringIsNil-CannotDetermineLineOfSight", code: 5, userInfo: nil)
    static let Error_JSONIsEmpty = NSError(domain: "ElevationProfileJSONStringIsEmpty-CannotDetermineLineOfSight", code: 6, userInfo: nil)
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
    var elevationProfileJSONString: String?
    var altitudeJSONString: String?
    
    var currentLocationDelegate: CurrentLocationDelegate?
    
    var parser: GeonamesJSONParser!

    weak var elevationManagerDelegate: ElevationManagerDelegate?
    weak var altitudeManagerDelegate: AltitudeManagerDelegate?
    
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
    
    func getElevationProfileData() {
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
    
    func receivedElevationProfileJSON(json: String?) {
        println("received elevation profile JSON data")

        if let jsonString = json {
            if !jsonString.isEmpty {
                let (elevationProfileArray, error) = parser.buildAndReturnArrayFromJSON(jsonString)
                
                if let parserError = error {
                    elevationManagerDelegate?.parsingElevationProfileFailedWithError(parserError)
                } else {
                    if nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfileArray) {
                        elevationManagerDelegate?.currentLocationCanViewNearbyPoint(self)
                    }
                }
            } else {
                fetchingError = NearbyPointConstants.Error_JSONIsEmpty
                println("fetching error: \(fetchingError!)")
            }
        } else {
            fetchingError = NearbyPointConstants.Error_JSONIsNil
            println("fetching error: \(fetchingError!)")
        }
    }
    
    func nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile: [AnyObject]?) -> Bool {
        if elevationProfile != nil && !elevationProfile!.isEmpty {
            if let elevationPoints = elevationProfile as? [CLLocation] {
                for elevationPoint in elevationPoints {
                    let currentLocation = currentLocationDelegate?.currentLocation
                    let o = elevationPoint.altitude - currentLocation!.altitude
                    let a = currentLocation!.distanceFromLocation(elevationPoint)
                    let lineOfSightAngleToElevationPoint = atan(o/a)*(180.0/M_PI)
                    
                    if lineOfSightAngleToElevationPoint > angleToHorizon {
                        return false
                    }
                }
                return true
            } else {
                return false // test
            }
        } else {
            return false
        }
    }
    
    func fetchingAltitudeFailedWithError(error: NSError) {
        println("fetchingAltitudeFailedWithError: \(error)")
        fetchingError = error
        altitudeManagerDelegate?.gettingAltitudeFailedWithError(error)
    }
    
    func receivedAltitudeJSON(json: String) {
        println("got altitude data")
        altitudeJSONString = json
        let (altitude, error) = parser.buildAndReturnArrayFromJSON(json)
        
        if let parserError = error {
            altitudeManagerDelegate?.parsingAltitudeFailedWithError(parserError)
        }
        
        if let altitudeArray = altitude as? [NSInteger] {
            if let altitudeValue = altitudeArray.first {
                location = CLLocation(coordinate: location.coordinate, altitude: Double(altitudeValue), horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, timestamp: location.timestamp)
                altitudeManagerDelegate?.successfullyRetrievedAltitude(self)
            }
        }
    }
    
    // TEST
    func showName(sender: UIButton!) {
        labelTapDelegate?.didReceiveTapForNearbyPoint(self)
    }
    // TEST
}
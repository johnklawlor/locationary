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

class NearbyPoint: AltitudeCommunicatorDelegate, Equatable, Printable {
    
    var description: String {
        var descriptionString = "\n name: \(name), \n location: \(location)"
        if distanceFromCurrentLocation != nil {
            descriptionString += ", \n distanceFromCurrentLocation: \(distanceFromCurrentLocation)"
        }
        if angleToCurrentLocation != nil {
            descriptionString += ", \n angleToCurrentLocation: \(angleToCurrentLocation)"
        }
        if angleToHorizon != nil {
            descriptionString += ", \n angleToHorizon: \(angleToHorizon)"
        }
        return descriptionString
    }
    
    init(aName: String, aLocation: CLLocation!) {
        name = aName
        location = aLocation
        parser = GeoNamesJSONParser()
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
            let tapRecognizer = UITapGestureRecognizer(target: label, action: "showName:")
//            label.userInteractionEnabled = true
            label.addGestureRecognizer(tapRecognizer)
        }
    }
    // TEST THIS!
    
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
    func showName(gesture: UITapGestureRecognizer){
        if gesture.numberOfTapsRequired == 1 {
            switch gesture.state {
            case .Ended:
                labelTapDelegate?.didReceiveTapForNearbyPoint(self)
            default: break
            }
        }
    }
    // TEST
}
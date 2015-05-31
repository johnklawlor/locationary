//
//  GeonamesManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

func == (lhs: GeonamesJSONParser, rhs: GeonamesJSONParser) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

protocol GeonamesCommunicatorDelegate {
    func fetchingNearbyPointsFailedWithError(error: NSError)
    func receivedNearbyPointsJSON(json: String)
}

class GeonamesCommunicator: Communicator, CommunicatorDelegate {

    var geonamesCommunicatorDelegate: GeonamesCommunicatorDelegate? {
        didSet {
            self.communicatorDelegate = self
        }
    }
    
    func fetchingFailedWithError(error: NSError) {
        geonamesCommunicatorDelegate?.fetchingNearbyPointsFailedWithError(error)
    }
    
    func receivedJSON(json: String) {
        geonamesCommunicatorDelegate?.receivedNearbyPointsJSON(json)
    }

    override var fetchingUrl: NSURL? {
        if currentLocation != nil {
            return NSURL(string: "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=\(south.format())&north=\(north.format())&west=\(west.format())&east=\(east.format())&orderby=elevation&username=jkl234")
        } else {
            return nil
        }
    }
    
    var currentLocation: CLLocation? {
        willSet {
            if currentLocation != nil {
                if currentLocation == newValue {
                    requestAttempts++
                } else {
                    requestAttempts = 1
                }
            } else {
                requestAttempts = 1
            }
        }
    }
    let dlat: Double = (1/110.54) * CommunicatorConstants.DistanceGeonamesPointsMustFallWithin
    var dlong: Double {
        if currentLocation != nil {
            println("returning calculated dlong")
            return CommunicatorConstants.DistanceGeonamesPointsMustFallWithin * (1/(111.32*cos(currentLocation!.coordinate.latitude*M_PI/180)))
        }
        return 0.063494
    }
    var north: Double { println("north: \(currentLocation!.coordinate.latitude + dlat)"); return currentLocation!.coordinate.latitude + dlat}
    var south: Double { println("south: \(currentLocation!.coordinate.latitude - dlat)"); return currentLocation!.coordinate.latitude - dlat }
    var east: Double { println("east: \(currentLocation!.coordinate.longitude + dlong)"); return currentLocation!.coordinate.longitude + dlong }
    var west: Double { println("west: \(currentLocation!.coordinate.longitude - dlong)"); return currentLocation!.coordinate.longitude - dlong }
    
    override init() {
        super.init()
    }
    
}

extension Double {
    func format() -> String {
        return NSString(format: "%0.6f", self) as String
    }
}
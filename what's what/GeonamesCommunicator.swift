//
//  GeonamesManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

struct GeonamesCommunicatorConstants {
    static let DistanceGeonamesPointsMustFallWithin: Double = 100.0
    static let MaxRows = 2000
}

func == (lhs: GeonamesJSONParser, rhs: GeonamesJSONParser) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

protocol GeonamesCommunicatorDelegate {
    func fetchingNearbyPointsFailedWithError(error: NSError)
    func receivedNearbyPointsJSON(json: String)
}

class GeonamesCommunicator: Communicator, CommunicatorDelegate {
    
    var startRowCount: Int = 0
    var startRow: Int {
        return startRowCount * GeonamesCommunicatorConstants.MaxRows
    }

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
            // non-production is api.geonames.org, change maxRows to 2000
            return NSURL(string: "http://ws.geonames.net/searchJSON?q=&featureClass=R&featureClass=H&featureClass=T&south=\(south.formatLocation())&north=\(north.formatLocation())&west=\(west.formatLocation())&east=\(east.formatLocation())&orderby=elevation&username=jkl234&maxRows=\(GeonamesCommunicatorConstants.MaxRows)&startRow=\(startRow)")
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
    let dlat: Double = (1/110.54) * GeonamesCommunicatorConstants.DistanceGeonamesPointsMustFallWithin
    var dlong: Double {
        if currentLocation != nil {
//            println("returning calculated dlong")
            return GeonamesCommunicatorConstants.DistanceGeonamesPointsMustFallWithin * (1/(111.32*cos(currentLocation!.coordinate.latitude*M_PI/180)))
        }
        return 0.063494
    }
    var south: Double { return currentLocation!.coordinate.latitude - dlat }
    var north: Double { return currentLocation!.coordinate.latitude + dlat}
    var west: Double { return currentLocation!.coordinate.longitude - dlong }
    var east: Double { return currentLocation!.coordinate.longitude + dlong }
    
//    hanover coordinates
//    43.705238, -72.287822
//    44.605238 42.805238 -73.527822 -71.047822
//    0.90, 1.24
//    http://api.geonames.org/searchJSON?q=&featureCode=MT&south=42.805238&north=44.605238&west=-73.527822&east=-71.047822&orderby=elevation&username=jkl234&maxRows=1000&startRow=0
    
    override init() {
        super.init()
    }
    
}
//
//  GoogleMapsCommunicator.swift
//  what's what
//
//  Created by John Lawlor on 4/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

protocol GoogleMapsCommunicatorDelegate {
    func fetchingElevationProfileFailedWithError(error: NSError)
    func receivedElevationProfileJSON(json: String?)
}

class GoogleMapsCommunicator: Communicator, CommunicatorDelegate {
    
    var googleMapsCommunicatorDelegate: GoogleMapsCommunicatorDelegate? {
        didSet {
            self.communicatorDelegate = self
        }
    }
    var currentLocation: CLLocation?
    var locationOfNearbyPoint: CLLocation?
    
    var currentLocationString: String {
        return "\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)"
    }
    
    var locationOfNearbyPointString: String {
        return "\(locationOfNearbyPoint!.coordinate.latitude),\(locationOfNearbyPoint!.coordinate.longitude)"
    }
    
    override var fetchingUrl: NSURL? {
        if currentLocation != nil && locationOfNearbyPoint != nil {
            return NSURL(string: "http://maps.googleapis.com/maps/api/elevation/json?path=\(currentLocationString)%7C\(locationOfNearbyPointString)&samples=10")
        } else {
            return nil
        }
    }
    
    func fetchingFailedWithError(error: NSError) {
        googleMapsCommunicatorDelegate?.fetchingElevationProfileFailedWithError(error)
    }
    
    func receivedJSON(json: String) {
        googleMapsCommunicatorDelegate?.receivedElevationProfileJSON(json)
    }
}
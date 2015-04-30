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
    func receivedElevationProfileJSON(json: String)
}

class GoogleMapsCommunicator {
    var googleMapsCommunicatorDelegate: GoogleMapsCommunicatorDelegate?
    var currentLocation: CLLocation?
    var locationOfNearbyPoint: CLLocation?
    
    func fetchElevationProfileJSONData() {
        
    }
}
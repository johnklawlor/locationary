//
//  MockNearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockNearbyPointsManager: NearbyPointsManager, GeonamesCommunicatorDelegate {
    
    var retrievalCount = 0
    
    override func receivedNearbyPointsJSON(json: String) {
        nearbyPointsJSON = json
    }
    
    override func successfullyRetrievedAltitude(nearbyPoint: NearbyPoint) {
        retrievalCount++
    }
}

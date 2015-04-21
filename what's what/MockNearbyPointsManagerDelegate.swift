//
//  MockNearbyPointsManagerDelegate.swift
//  what's what
//
//  Created by John Lawlor on 3/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import CoreLocation

class MockNearbyPointsManagerDelegate: NearbyPointsManagerDelegate {
    
    var failError: NSError?
    var successfullyAssembledNearbyPointsArray: Bool! = false
    
    func fetchingFailedWithError(error: NSError) {
        failError = error
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        successfullyAssembledNearbyPointsArray = true
    }
    
    func retrievedNearbyPointsWithAltitude(nearbyPoint: NearbyPoint) {
        
    }
    
    init() {
        
    }
}
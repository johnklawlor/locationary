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
    var updatedNearbyPoints = [NearbyPoint]()
    var retrievedPoint: NearbyPoint?
    
    func fetchingFailedWithError(error: NSError) {
        failError = error
    }
    
    func assembledNearbyPointsWithoutAltitude() {
        successfullyAssembledNearbyPointsArray = true
    }
    
    func retrievedNearbyPointWithAltitudeAndUpdatedDistance(nearbyPoint: NearbyPoint) {
        retrievedPoint = nearbyPoint
    }
    
    func updatedNearbyPointsWithAltitudeAndUpdatedDistance(nearbyPoints: [NearbyPoint]) {
        updatedNearbyPoints = nearbyPoints
    }
    
    init() {
        
    }
}
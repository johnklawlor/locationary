//
//  MockNearbyPointsManagerTwo.swift
//  what's what
//
//  Created by John Lawlor on 6/3/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockNearbyPointsManagerTwo: NearbyPointsManager {
    
    var askedToCalculateDistance: Bool = false
    var askedToCalculateAbsoluteAngleWithCurrentLocationAsOrigin: Bool = false
    var askedToUpdateElevationAndAngleToHorizon: Bool = false
    
    override func calculateDistanceFromCurrentLocation(nearbyPoint: NearbyPoint) {
        askedToCalculateDistance = true
    }
    
    override func calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint: NearbyPoint) {
        askedToCalculateAbsoluteAngleWithCurrentLocationAsOrigin = true
    }
    
    override func updateElevationAndAngleToHorizonForPoint(nearbyPoint: NearbyPoint, elevation: Double, angleToHorizon: Double) {
        askedToUpdateElevationAndAngleToHorizon = true
    }
    
}

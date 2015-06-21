//
//  MockElevationDataManager.swift
//  what's what
//
//  Created by John Lawlor on 6/2/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit

class MockElevationDataManager: ElevationDataManager {
    
    var numberOfTimesAskedToGetElevationData = 0

    override func getElevationForPoint(nearbyPoint: NearbyPoint) {
        numberOfTimesAskedToGetElevationData += 1
        if let mockPoint = nearbyPoint as? MockPoint {
            mockPoint.askedToGetElevationData = true
        }
    }
    
}
//
//  MockElevationDataManager.swift
//  what's what
//
//  Created by John Lawlor on 6/2/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit

class MockElevationDataManager: ElevationDataManager {
    
    var askedToGetElevationData: Bool = false

    override func getElevationForPoint(nearbyPoint: NearbyPoint) {
        askedToGetElevationData = true
    }
    
}
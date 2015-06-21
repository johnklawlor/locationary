//
//  MockPoint.swift
//  what's what
//
//  Created by John Lawlor on 4/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit

class MockPoint: NearbyPoint {
    var askedToGetElevationData = false
    
    init(nearbyPoint: NearbyPoint) {
        super.init(aName: nearbyPoint.name, aLocation: nearbyPoint.location)
    }
}
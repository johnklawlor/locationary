//
//  MockNearbyPoint.swift
//  what's what
//
//  Created by John Lawlor on 4/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockPoint: NearbyPoint {
    var askedToDetermineIfInLineOfSight: Bool! = false
    
    override func determineIfInLineOfSight() {
        askedToDetermineIfInLineOfSight = true
    }
}
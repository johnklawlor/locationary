//
//  MockPointTwo.swift
//  what's what
//
//  Created by John Lawlor on 5/7/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockPointTwo: NearbyPoint {
    override func nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile: [AnyObject]?) -> Bool {
        if let anyObject = elevationProfile {
            return true
        } else {
            return false
        }
    }
}
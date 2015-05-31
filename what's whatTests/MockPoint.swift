//
//  MockPoint.swift
//  what's what
//
//  Created by John Lawlor on 4/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockPoint: NearbyPoint {
    var receivedJSON: String?
    var askedToDetermineIfInLineOfSight: Bool! = false
    var askedToGetJSONData: Bool = false
    
    var failError: NSError?
    var jsonString: String?
    
    override func receivedJSON(json: String) {
        receivedJSON = json
    }
    
    override func getElevationProfileData() {
        askedToDetermineIfInLineOfSight = true
    }
    
    override func fetchingElevationProfileFailedWithError(error: NSError) {
        failError = error
    }
    
    override func receivedElevationProfileJSON(json: String?) {
        jsonString = json
    }
    
    override func nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile: [AnyObject]?) -> Bool {
        if let anyObject = elevationProfile {
            return true
        } else {
            return false
        }
    }
    
}
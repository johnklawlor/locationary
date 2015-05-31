//
//  MockNearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockNearbyPointsManager: NearbyPointsManager, CommunicatorDelegate {
    
    var retrievalCount = 0
    var updatedDistances: Bool! = false
    var askedToGetGeonamesJSONData: Bool! = false
    var askedToDetermineIfEachPointIsInLineOfSight: Bool! = false
    var informedOfNearbyPointInLineOfSight: Bool = false
    var informedOfNearbyPointNOTInLineOfSight: Bool = false
    var askedToGetAltitudeJSONDataForEachPoint: Bool = false
    var askedToGetElevationProfileDataForPoint: Bool = false
    var didUpdateDistancesAndAnglesForPoint: Bool = false
    
    var nearbyPointToUpdate: NearbyPoint!
    
    override func receivedNearbyPointsJSON(json: String) {
        nearbyPointsJSON = json
    }
    
    func fetchingFailedWithError(error: NSError) {
    }
    
    func receivedJSON(json: String) {
    }
    
    override func updateDistanceOfNearbyPointsWithAltitude() {
        updatedDistances = true
    }
    
    override func getGeonamesJSONData() {
        askedToGetGeonamesJSONData = true
    }
    
    override func determineIfEachPointIsInLineOfSight() {
        askedToDetermineIfEachPointIsInLineOfSight = true
    }
    
    override func currentLocationCanViewNearbyPoint(nearbyPoint: NearbyPoint) {
        informedOfNearbyPointInLineOfSight = true
    }
    
    override func currentLocationCANNOTViewNearbyPoint(nearbyPoint: NearbyPoint) {
        informedOfNearbyPointNOTInLineOfSight = true
    }
    
    override func getElevationProfileDataForPoint(nearbyPoint: NearbyPoint) {
        askedToGetElevationProfileDataForPoint = true
    }
    
    override func updateDistancesAndAnglesForPoint(nearbyPoint: NearbyPoint) {
        didUpdateDistancesAndAnglesForPoint = true
    }
}

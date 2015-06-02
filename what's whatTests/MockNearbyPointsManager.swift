//
//  MockNearbyPointsManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockNearbyPointsManager: NearbyPointsManager, CommunicatorDelegate, ElevationDataDelegate {
    
    var retrievalCount = 0
    var updatedDistances: Bool! = false
    var askedToGetGeonamesJSONData: Bool! = false
    var askedToDetermineIfEachPointIsInLineOfSight: Bool! = false
    var informedOfNearbyPointInLineOfSight: Bool = false
    var informedOfNearbyPointNOTInLineOfSight: Bool = false
    var askedToGetAltitudeJSONDataForEachPoint: Bool = false
    var askedToGetElevationProfileDataForPoint: Bool = false
    var didUpdateDistancesAndAnglesForPoint: Bool = false
    var askedToCalculateAbsoluteAngleWithCurrentLocationAsOrigin: Bool = false
    var askedToUpdateElevationAndAngleToHorizon: Bool = false
    var askedToCalculateDistance: Bool = false
    
    var nearbyPointToUpdate: NearbyPoint!
    var elevationDataForPointToUpdate: ElevationData!
    
    override func receivedNearbyPointsJSON(json: String) {
        nearbyPointsJSON = json
    }
    
    func fetchingFailedWithError(error: NSError) {
    }
    
    func receivedJSON(json: String) {
    }
    
    override func getGeonamesJSONData() {
        askedToGetGeonamesJSONData = true
    }
    
    override func determineIfEachPointIsInLineOfSight() {
        askedToDetermineIfEachPointIsInLineOfSight = true
    }
    
    override func calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint: NearbyPoint) {
        askedToCalculateAbsoluteAngleWithCurrentLocationAsOrigin = true
    }
    
    override func updateElevationAndAngleToHorizonForPoint(nearbyPoint: NearbyPoint, elevation: Double, angleToHorizon: Double) {
        askedToUpdateElevationAndAngleToHorizon = true
    }
    
    override func calculateDistanceFromCurrentLocation(nearbyPoint: NearbyPoint) {
        askedToCalculateDistance = true
    }
    
    override func processElevationProfileDataForPoint(nearbyPoint: NearbyPoint, elevationData: ElevationData) {
        elevationDataForPointToUpdate = elevationData
        nearbyPointToUpdate = nearbyPoint
    }
    
}

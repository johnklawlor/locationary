//
//  MockNearbyPointsManager.swift
//  Locationary
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 John Lawlor. All rights reserved.
//
//  This file is part of Locationary.
//
//  Locationary is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Locationary is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
    
    override func determineIfEachRecentlyRetrievedPointIsInLineOfSight() {
        askedToDetermineIfEachPointIsInLineOfSight = true
    }
    
    override func processElevationProfileDataForPoint(nearbyPoint: NearbyPoint, elevationData: ElevationData) {
        elevationDataForPointToUpdate = elevationData
        nearbyPointToUpdate = nearbyPoint
    }
    
}

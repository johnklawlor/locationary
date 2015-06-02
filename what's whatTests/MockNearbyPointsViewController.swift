//
//  MockNearbyPointsViewController.swift
//  what's what
//
//  Created by John Lawlor on 4/23/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

class MockNearbyPointsViewController: NearbyPointsViewController {
    
    var preparingForNearbyPoints: Bool! = false
    var createdNewNearbyPointsManager: Bool! = false
    var informedOfSuccessfullyFindingNearbyPointInLineOfSight: Bool = false
    
    override func prepareForNewPointsAtLocation(location: CLLocation!) {
        nearbyPointsManager = MockNearbyPointsManager(delegate: NearbyPointsViewController())
    }
    
    override func createNewNearbyPointsManager() {
        createdNewNearbyPointsManager = true
    }
    
    override func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint) {
        informedOfSuccessfullyFindingNearbyPointInLineOfSight = true
    }
    
}

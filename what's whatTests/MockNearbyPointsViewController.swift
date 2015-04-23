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
    
    override func prepareForNearbyPointsWithAltitudeForLocation(location: CLLocation!) {
        nearbyPointsManager = MockNearbyPointsManager()
    }
}

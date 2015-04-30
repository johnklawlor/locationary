//
//  MockGoogleMapsCommunicator.swift
//  what's what
//
//  Created by John Lawlor on 4/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockGoogleMapsCommunicator: GoogleMapsCommunicator {
    var askedToFetchJSONData: Bool! = false
    
    override func fetchElevationProfileJSONData() {
        askedToFetchJSONData = true
    }
}
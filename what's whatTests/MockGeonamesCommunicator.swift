//
//  MockGeonamesCommunicatorTests.swift
//  what's what
//
//  Created by John Lawlor on 3/29/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockGeonamesCommunicator: GeonamesCommunicator {
    var askedToFetchedJSON: Bool! = false
    var askedToFetchAltitudeJSON: Bool! = false
    
    override func fetchGeonamesJSONData() {
        askedToFetchedJSON = true
    }
}
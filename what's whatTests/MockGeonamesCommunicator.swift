//
//  MockGeonamesCommunicatorTests.swift
//  what's what
//
//  Created by John Lawlor on 3/29/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockGeonamesCommunicator: GeonamesCommunicator, CommunicatorDelegate {
    var askedToFetchedJSON: Bool! = false
    var askedToFetchAltitudeJSON: Bool! = false
    var receivedJSON: String!
    
    var fetchingError: NSError!
    
    override func fetchingFailedWithError(error: NSError) {
        fetchingError = error
    }
    
    override func fetchJSONData() {
        askedToFetchedJSON = true
    }
    
    override func receivedJSON(json: String) {
        receivedJSON = json
    }
}
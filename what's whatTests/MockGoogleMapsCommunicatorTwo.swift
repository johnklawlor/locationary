//
//  MockGoogleMapsCommunicatorTwo.swift
//  what's what
//
//  Created by John Lawlor on 5/7/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockGoogleMapsCommunicatorTwo: MockCommunicatorTwo, CommunicatorDelegate {
    var wasNotifiedByCommunicator: Bool = false
    
    func receivedJSON(json: String) {
        wasNotifiedByCommunicator = true
    }
    
    func fetchingFailedWithError(error: NSError) {
    }
}
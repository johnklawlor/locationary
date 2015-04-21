//
//  MockAltitudeCommunicator.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockAltitudeCommunicator: AltitudeCommunicator {
    var askedToFetchJSONData: Bool! = false
    
    override func fetchAltitudeJSONData() {
        askedToFetchJSONData = true
    }
    
    func setTheReceivedData(data: NSData) {
        receivedData = data.mutableCopy() as? NSMutableData
    }
}
//
//  MockCommunicatorTwo.swift
//  what's what
//
//  Created by John Lawlor on 5/7/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class MockCommunicatorTwo: Communicator {
    
    override func fetchJSONData() {
        communicatorDelegate?.receivedJSON("Elevation data")
    }
    
}
//
//  NNGeonamesCommunicator.swift
//  what's what
//
//  Created by John Lawlor on 3/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class NNGeonamesCommunicator: GeonamesCommunicator {
    
    func setTheReceivedData(data: NSData) {
        receivedData = data.mutableCopy() as? NSMutableData
    }
    
    override func launchConnectionForRequest(request: NSURLRequest) {
    }
}
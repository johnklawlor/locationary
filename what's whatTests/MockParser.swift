//
//  MockParser.swift
//  what's what
//
//  Created by John Lawlor on 3/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

class MockParser: GeonamesJSONParser {
    
    var parserError: NSError?
    var parserTotalPoints: Int?
    var parserPoints: [AnyObject]?
    
    override func buildAndReturnArrayFromJSON(json: String) -> ([AnyObject]?, Int?, NSError?) {
        return (parserPoints, parserTotalPoints, parserError)
    }
}
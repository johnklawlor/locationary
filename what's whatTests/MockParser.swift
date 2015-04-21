//
//  MockParser.swift
//  what's what
//
//  Created by John Lawlor on 3/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

class MockParser: GeoNamesJSONParser {
    
    var parserError: NSError?
    var parserPoints: [AnyObject]?
    
    override func buildAndReturnArrayFromJSON(json: String) -> ([AnyObject]?, NSError?) {
        return (parserPoints, parserError)
    }
}
//
//  MockHeading.swift
//  what's what
//
//  Created by John Lawlor on 4/3/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

class MockHeading: CLHeading {
    
    init(heading: Double, accuracy: Double = 0) {
        super.init()
        setHeading = heading
        setAccuracy = accuracy
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var setHeading: CLLocationDirection!
    var setAccuracy: CLLocationDirection!
    
    override var trueHeading: CLLocationDirection {
        return setHeading
    }
    
    override var headingAccuracy: CLLocationDirection {
        return setAccuracy
    }
}

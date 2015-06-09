//
//  MockDoubleTap.swift
//  what's what
//
//  Created by John Lawlor on 6/4/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit

class MockDoubleTap: UITapGestureRecognizer {

    init(point: CGPoint) {
        super.init(target: "", action: "")
        location = point
    }
    
    var location: CGPoint = CGPoint(x: 0, y: 0)
    override var state: UIGestureRecognizerState {
        return .Ended
    }
    
    override func locationInView(view: UIView?) -> CGPoint {
        return location
    }
    
}
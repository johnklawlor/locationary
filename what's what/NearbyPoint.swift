//
//  NearbyPoint.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

func == (lhs: NearbyPoint, rhs: NearbyPoint) -> Bool {
    if lhs.location == rhs.location {
        if lhs.name == lhs.name {
            return true
        }
    }
    return false
}

protocol LabelTapDelegate {
    func didReceiveTapForNearbyPoint(nearbyPoint: NearbyPoint)
}

struct NearbyPointConstants {
    static let LabelFrameSize: CGFloat = 40.0
}

class NearbyPoint: NSObject, Equatable, Printable {
    
    override var description: String {
        return "\(name): \(location) \n \(distanceFromCurrentLocation), \(angleToCurrentLocation) from current location, and \(angleToHorizon) from horizon"
    }
    
    init(aName: String, aLocation: CLLocation!) {
        name = aName
        location = aLocation
    }
    
    let name: String!
    var location: CLLocation!
    var distanceFromCurrentLocation: CLLocationDistance!
    var angleToCurrentLocation: Double!
    var angleToHorizon: Double!
    
    // TEST
    var labelTapDelegate: LabelTapDelegate?
    // TEST
    
    // TEST THIS!
    var label: UIButton! {
        didSet {
            label.addTarget(self, action: "showName:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    // TEST THIS!
    
    func showName(sender: UIButton!) {
        labelTapDelegate?.didReceiveTapForNearbyPoint(self)
    }
}
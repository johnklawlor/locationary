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

func convertToFeet(distanceInMeters: CLLocationDistance) -> Double {
    return distanceInMeters * 3.2808399
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
    
    var distanceFromCurrentLocationInMiles: Double {
        return convertToFeet(distanceFromCurrentLocation)/5280
    }
    
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

extension CLLocation {
    var altitudeInFeet: CLLocationDistance {
        return convertToFeet(self.altitude)
    }
    
    var formattedCoordinate: String {
        return self.coordinate.latitude.formatLocation() + ", " + self.coordinate.longitude.formatLocation()
    }
}

extension Double {
    func formatLocation() -> String {
        return NSString(format: "%0.6f", self) as String
    }
    
    func formatFeet() -> String {
        return NSString(format: "%0.0f", self) as String
    }
    
    func formatMiles() -> String {
        return NSString(format: "%0.1f", self) as String
    }
}
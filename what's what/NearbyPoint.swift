//
//  NearbyPoint.swift
//  Locationary
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 John Lawlor. All rights reserved.
//
//  This file is part of Locationary.
//
//  Locationary is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Locationary is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

protocol ScreenSizeDelegate{
    var DeviceConstants: Constants! { get }
}

struct NearbyPointConstants {
    static let LabelFrameSize: CGFloat = 60.0
}

class NearbyPoint: NSObject {
    
    override var description: String {
        return "\(name): \(location) \n \(location.altitude) \n \(distanceFromCurrentLocation), \(angleToCurrentLocation) from current location, and \(angleToHorizon) from horizon"
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
    
    var screenSizeDelegate: ScreenSizeDelegate?
    // TEST
    
    // TEST THIS!
    var label: UIButton! {
        didSet {
            label.addTarget(self, action: "showName:",
                forControlEvents: [UIControlEvents.TouchDown,
                                    UIControlEvents.TouchDragEnter,
                                    UIControlEvents.TouchDragExit,
                                    UIControlEvents.TouchDragInside,
                                    UIControlEvents.TouchDragOutside] )
        }
    }
    // TEST THIS!
    
    func showName(sender: UIButton!) {
        labelTapDelegate?.didReceiveTapForNearbyPoint(self)
    }
    
    func formattedDistanceStringsForUnits(units: Int) -> (elevationString: String, distanceString: String) {
        if units == 1 {
            let elevationString = "\(self.location.altitudeInFeet.formatShortDistance()) feet high"
            let distanceString = "\(self.distanceFromCurrentLocationInMiles.formatLongDistance()) miles away"
            return (elevationString, distanceString)
        } else {
            let elevationString = "\(self.location.altitude.formatShortDistance()) meters high"
            let distanceString = "\(self.distanceFromCurrentLocation.formatLongDistance()) kilometers away"
            return (elevationString, distanceString)
        }
    }
    
    func makeLabelButton() {
        let labelFrame = CGRectMake(
            screenSizeDelegate!.DeviceConstants.PhoneHeight/2.0,
            0,
            NearbyPointConstants.LabelFrameSize,
            NearbyPointConstants.LabelFrameSize)
        let labelButton = UIButton()
        labelButton.frame = labelFrame
        labelButton.layer.zPosition = CGFloat(1/distanceFromCurrentLocation)
        self.label = labelButton
        
        // TEST
        
        let altitude = self.location.altitude
        let rectangleSize = pow(altitude,0.5)/4+20
//        let rectangleSize = (1500000/(100000+pow(distanceFromCurrentLocation,1.25))+20)
        let theButtonImage = UIImage(named: "overlaygraphic.png")
        let rectangle = CGRect(x: 0, y: 0, width: rectangleSize, height: rectangleSize)
        UIGraphicsBeginImageContextWithOptions(rectangle.size, false, 0.0);
        theButtonImage?.drawInRect(rectangle)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let buttonImage = newImage
        
        self.label.setImage(buttonImage, forState: UIControlState.Normal)
        
        let firstInitialLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: labelFrame.size))
        let firstCharacterIndex = self.name.startIndex.advancedBy(0)
        let firstLetterOfNearbyPointName = String(self.name[firstCharacterIndex])
        firstInitialLabel.text = firstLetterOfNearbyPointName
        let fontSize = CGFloat(rectangleSize/2.0)
        firstInitialLabel.font = UIFont(name: "Helvetica Neue", size: fontSize)
        firstInitialLabel.textAlignment = .Center
        firstInitialLabel.textColor = UIColor.whiteColor()
        firstInitialLabel.userInteractionEnabled = false
        
        labelButton.hidden = true
        self.label.addSubview(firstInitialLabel)
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
    
    func formatShortDistance() -> String {
        return NSString(format: "%0.0f", self) as String
    }
    
    func formatLongDistance() -> String {
        return NSString(format: "%0.1f", self) as String
    }
    
    func inDegrees() -> Double {
        return self * (180.0/M_PI)
    }
}
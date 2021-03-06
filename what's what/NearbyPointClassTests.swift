//
//  NearbyPointClassTests.swift
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
import XCTest
import CoreLocation

class TestPoints {
    var Point1 = NearbyPoint(aName: "Smarts Mountain", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: 962, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var Point2 = NearbyPoint(aName: "Mount Cardigan", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.649675, -71.914211), altitude: 940, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var Point3 = NearbyPoint(aName: "Mount Far Away", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(40.12563, -80.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    
    var Holts = NearbyPoint(aName: "Holts Ledge", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.772333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var NearHolts = NearbyPoint(aName: "Holts Ledge", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.773333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var Smarts = NearbyPoint(aName: "Smarts Mountain", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: 962, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var MooseNorth = NearbyPoint(aName: "Moose Mountain, North", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.741299, -72.136657), altitude: 702, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var MooseSouth = NearbyPoint(aName: "Moose Mountain, South", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.720343, -72.145562), altitude: 694, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var Winslow = NearbyPoint(aName: "Winslow", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.776346, -72.077457), altitude: 693, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var BreadLoaf = NearbyPoint(aName: "Bread Loaf", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(44.002280,-72.941500), altitude: 1169, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var Schindlers = NearbyPoint(aName: "Schindlers", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.833084, -72.250574), altitude: 187, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var Killington = NearbyPoint(aName: "Killington", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.604598, -72.819852), altitude: 1272, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var Cardigan = NearbyPoint(aName: "Mount Cardigan", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.649693, -71.914854), altitude: 935, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var Washington = NearbyPoint(aName: "Mount Washington", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(44.270582, -71.303299), altitude: 1908, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var MockHolts = NearbyPoint(aName: "Holts", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.772333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    var GoosePond = NearbyPoint(aName: "Goose Pond", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.736985, -72.105721), altitude: 280, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var MountWashington = NearbyPoint(aName: "Mount Washington", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(44.270490,-71.303460), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var CliffSt = NearbyPoint(aName: "Cliff St", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.717368, -72.306219), altitude: 176, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var MapleAndWilley = NearbyPoint(aName: "Maple And Willey", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.730680, -72.295978), altitude: 295, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var MountSupport = NearbyPoint(aName: "Mount Support", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.67563, -72.25592), altitude: 169, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var Balch = NearbyPoint(aName: "Balch Hill", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.712570, -72.260920), altitude: 293, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var Ascutney = NearbyPoint(aName: "Ascutney", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.444516, -72.453702), altitude: 956, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var Gile = NearbyPoint(aName: "Gile", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.789053, -72.351619), altitude: 600, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    var Higley = NearbyPoint(aName: "Higley", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(42.893690, -72.790650), altitude: 693, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
}

struct Altitudes {
    static let HoltsToKillington = [614.346008300781,
        317.276916503906,
        118.771034240723,
        317.586242675781,
        220.008392333984,
        395.074798583984,
        357.749359130859,
        460.627288818359,
        661.596984863281,
        1287.99914550781].map({floor($0 / 0.000001) / 1000000})
}

struct Coordinates {
    static let HoltsToKillington = [[43.772333,-72.107691],
        [43.7539144376924,-72.1870163156887],
        [43.7354410486442,-72.2662927446971],
        [43.7169129020388,-72.3455202036827],
        [43.6983300671558,-72.4246986099388],
        [43.6796926133706,-72.5038278813945],
        [43.661000610153,-72.5829079366135],
        [43.6422541270662,-72.6619386947941],
        [43.6234532337661,-72.740920075768],
        [43.604598,-72.819852]]
}

class NearbyPointClassTests: XCTestCase {

    var point1, point2: NearbyPoint!
    var parser = MockParser()
    var parser2 = MockParser()
    var manager: MockNearbyPointsManager!
    var viewController = NearbyPointsViewController()
    var nearbyPoint: NearbyPoint!
    
    var testPoints = TestPoints()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name = "Smarts Mountain"
        point1 = NearbyPoint(aName: name, aLocation: location)
        let location2 = CLLocation(coordinate: CLLocationCoordinate2DMake(43.12563, -72.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name2 = "Mount Cardigan"
        point2 = NearbyPoint(aName: name, aLocation: location2)
        
        nearbyPoint = testPoints.Holts
        
        testPoints.Holts.label = UIButton()
        testPoints.Holts.labelTapDelegate = viewController
        
        nearbyPoint.label = UIButton()
        nearbyPoint.labelTapDelegate = viewController
        viewController.locationManager = CLLocationManager()
        viewController.view.addSubview(nearbyPoint.label)
        
        manager = MockNearbyPointsManager(delegate: viewController)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTapCallsTapAction() {
        testPoints.Holts.label.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertEqual(viewController.nearbyPointCurrentlyDisplayed!, testPoints.Holts, "Tapping button should call action")
    }
    
    func testNearbyPointLabelTapInformsDelegate() {
        testPoints.Holts.showName(testPoints.Holts.label)
        XCTAssertEqual(viewController.nearbyPointCurrentlyDisplayed!, testPoints.Holts, "NearbyPoint's tap delegate should be passed NearbyPoint")
    }

}

extension CLLocation {
    
    class func locationArrayFromCoordinates(coordinates: [[Double]], altitudes: [Double]) -> [CLLocation] {
        var elevationProfile = [CLLocation]()
        for (index, coordinate) in enumerate(coordinates) {
            let dc = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
            let altitude = altitudes[index]
            elevationProfile.append(CLLocation(coordinate: dc, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
        }
        return elevationProfile
    }
}

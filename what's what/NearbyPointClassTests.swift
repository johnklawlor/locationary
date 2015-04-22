//
//  NearbyPointClassTests.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

struct TestPoints {
    static let Point1 = NearbyPoint(aName: "Smarts Mountain", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    static let Point2 = NearbyPoint(aName: "Mount Cardigan", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.12563, -72.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    static let Point3 = NearbyPoint(aName: "Mount Far Away", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(40.12563, -80.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    
    static let Holts = NearbyPoint(aName: "Holts Ledge", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.772333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Smarts = NearbyPoint(aName: "Smarts Mountain", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: 962, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let MooseNorth = NearbyPoint(aName: "Moose Mountain, North", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.741299, -72.136657), altitude: 702, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let MooseSouth = NearbyPoint(aName: "Moose Mountain, South", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.720343, -72.145562), altitude: 694, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Cardigan = NearbyPoint(aName: "Mount Cardgian", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(
        43.655734, -71.910215), altitude: 962, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Winslow = NearbyPoint(aName: "Winslow", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.776346, -72.077457), altitude: 693, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
}

class NearbyPointClassTests: XCTestCase {

    var point1, point2: NearbyPoint!
    var altitudeCommunicator = AltitudeCommunicator()
    var nnAltitudeCommunicator = MockAltitudeCommunicator()
    var parser = MockParser()
    var parser2 = MockParser()
    var manager = MockNearbyPointsManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name = "Smarts Mountain"
        point1 = NearbyPoint(aName: name, aLocation: location)
        let location2 = CLLocation(coordinate: CLLocationCoordinate2DMake(43.12563, -72.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name2 = "Mount Cardigan"
        point2 = NearbyPoint(aName: name, aLocation: location2)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCallToSetJSONDataSetsCommunicatorsDelegateToSelfAndCommunicatorsLocationOfAltitudeToFetch() {
        point1.altitudeCommunicator = altitudeCommunicator
        point1.getAltitudeJSONData()
        XCTAssertEqual(point1.location, point1.altitudeCommunicator!.locationOfAltitudeToFetch!, "NearbyPoint should pass its location to its communicator")
        XCTAssertTrue(altitudeCommunicator.altitudeCommunicatorDelegate != nil, "NearbyPoint should be communicator's delegate")
    }
    
    func testCallToSetJSONDataCallsFetchJSONDataOnCommunicator() {
        point1.altitudeCommunicator = nnAltitudeCommunicator
        point1.getAltitudeJSONData()
        XCTAssertTrue(nnAltitudeCommunicator.askedToFetchJSONData == true, "Call to NearbyPoint to set altitude data should make call to NearbyPoint's altitudeCommunicator")
    }

    func testCorrectlyParsedAltitudeJSONAddsAltitudeToNearbyPoint() {
        parser.parserPoints = [NSInteger(694)]
        parser.parserError = nil
        point1.parser = parser
        point1.receivedAltitudeJSON("JSON")
        XCTAssertEqual(point1.location.altitude, Double(694), "NearbyPoint should get altitude value from parser")
    }
    
    func testNearbyPointInformsManagerDelegateOfSuccessfulRetrievalOfAltitude() {
        
        parser.parserPoints = [123]
        point1.managerDelegate = manager
        point1.parser = parser

        parser2.parserPoints = [456]
        point2.managerDelegate = manager
        point2.parser = parser2
        
        point1.receivedAltitudeJSON("")
        
        point1.location = CLLocation(coordinate: point1.location.coordinate, altitude: 123, horizontalAccuracy: point1.location.horizontalAccuracy, verticalAccuracy: point1.location.verticalAccuracy, timestamp: point1.location.timestamp)
        point2.location = CLLocation(coordinate: point2.location.coordinate, altitude: 456, horizontalAccuracy: point2.location.horizontalAccuracy, verticalAccuracy: point2.location.verticalAccuracy, timestamp: point2.location.timestamp)
        
        XCTAssertEqual(manager.retrievalCount, 1, "NearbyPoint should inform manager delegate of successfully retrieving altitude")
        
        point2.receivedAltitudeJSON("")

        XCTAssertEqual(manager.retrievalCount, 2, "NearbyPoint should inform manager delegate of successfully retrieving altitude, and add to already assembled nearbyPointsWithAltitude array")
    }
}
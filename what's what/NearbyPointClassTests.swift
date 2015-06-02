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
    var MockHolts = MockPoint(aName: "Holts", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.772333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
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

//    func testCallToSetJSONDataSetsCommunicatorsDelegateToSelfAndCommunicatorsLocationOfAltitudeToFetch() {
//        point1.altitudeCommunicator = altitudeCommunicator
//        point1.getAltitudeJSONData()
//        XCTAssertEqual(point1.location, point1.altitudeCommunicator!.locationOfAltitudeToFetch!, "NearbyPoint should pass its location to its communicator")
//        XCTAssertTrue(altitudeCommunicator.altitudeCommunicatorDelegate != nil, "NearbyPoint should be communicator's delegate")
//    }
    
//    func testCallToSetJSONDataCallsFetchJSONDataOnCommunicator() {
//        point1.altitudeCommunicator = nnAltitudeCommunicator
//        point1.getAltitudeJSONData()
//        XCTAssertTrue(nnAltitudeCommunicator.askedToFetchJSONData == true, "Call to NearbyPoint to set altitude data should make call to NearbyPoint's altitudeCommunicator")
//    }

//    func testCorrectlyParsedAltitudeJSONAddsAltitudeToNearbyPoint() {
//        parser.parserPoints = [NSInteger(694)]
//        parser.parserError = nil
//        point1.parser = parser
//        point1.receivedAltitudeJSON("JSON")
//        XCTAssertEqual(point1.location.altitude, Double(694), "NearbyPoint should get altitude value from parser")
//    }
    
//    func testNearbyPointInformsManagerDelegateOfSuccessfulRetrievalOfAltitude() {
//        
//        parser.parserPoints = [123]
//        point1.altitudeManagerDelegate = manager
//        point1.parser = parser
//
//        parser2.parserPoints = [456]
//        point2.altitudeManagerDelegate = manager
//        point2.parser = parser2
//        
//        point1.receivedAltitudeJSON("")
//        
//        point1.location = CLLocation(coordinate: point1.location.coordinate, altitude: 123, horizontalAccuracy: point1.location.horizontalAccuracy, verticalAccuracy: point1.location.verticalAccuracy, timestamp: point1.location.timestamp)
//        point2.location = CLLocation(coordinate: point2.location.coordinate, altitude: 456, horizontalAccuracy: point2.location.horizontalAccuracy, verticalAccuracy: point2.location.verticalAccuracy, timestamp: point2.location.timestamp)
//        
//        XCTAssertEqual(manager.retrievalCount, 1, "NearbyPoint should inform manager delegate of successfully retrieving altitude")
//        
//        point2.receivedAltitudeJSON("")
//
//        XCTAssertEqual(manager.retrievalCount, 2, "NearbyPoint should inform manager delegate of successfully retrieving altitude, and add to already assembled nearbyPointsWithAltitude array")
//    }
    
    func testTapCallsTapAction() {
        testPoints.Holts.label.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertEqual(viewController.nearbyPointCurrentlyDisplayed!, testPoints.Holts, "Tapping button should call action")
    }
    
    func testNearbyPointLabelTapInformsDelegate() {
        testPoints.Holts.showName(testPoints.Holts.label)
        XCTAssertEqual(viewController.nearbyPointCurrentlyDisplayed!, testPoints.Holts, "NearbyPoint's tap delegate should be passed NearbyPoint")
    }
    
    func testCallToDetermineLineOfSightWithNilCommunicatorSetsPrefetchError() {
    }
    
    func testDetermineLineOfSightWithoutCurrentLocationSetPrefetchError() {
//        nearbyPoint.googleMapsCommunicator = mockGoogleMapsCommunicator
//        manager.currentLocation = nil
//        nearbyPoint.currentLocationDelegate = manager
//        nearbyPoint.getElevationProfileData()
//        XCTAssertEqual(nearbyPoint.prefetchError!, NearbyPointConstants.Error_NoCurrentLocation, "nearbyPoint with a currentLocationDelegate that doesn't have a currentLocation sets a prefetch error")
    }
    
    func testPassingEmptyStringToReceivedElevationProfileJSONDataSetsFetchingError() {
//        nearbyPoint.receivedElevationProfileJSON("")
//        XCTAssertEqual(nearbyPoint.fetchingError!, NearbyPointConstants.Error_JSONIsEmpty, "Nil JSON string should set fetching error")
    }
    
    func testNearbyPointNotifiesManagerOfParseErrorEvenIfParserReturnsArray() {
//        nearbyPoint.elevationManagerDelegate = manager
//        parser.parserError = ParserConstants.Error_SerializedJSONPossiblyNotADictionary
//        nearbyPoint.parser = parser
//        nearbyPoint.receivedElevationProfileJSON("JSON")
//        XCTAssertEqual(manager.parsingError!, ParserConstants.Error_SerializedJSONPossiblyNotADictionary, "ElevationManagerDelegate should be passed parsing error")
    }
    
    func testNearbyPointInLineOfSightOfCurrentLocationInformsDelegate() {
//        var mockPoint = MockPointTwo(aName: "Mountain", aLocation: CLLocation())
//        parser.parserError = nil
//        mockPoint.parser = parser
//        parser.parserPoints = [CLLocation()]
//        mockPoint.elevationManagerDelegate = manager
//        mockPoint.receivedElevationProfileJSON("JSON")
//        XCTAssertTrue(manager.informedOfNearbyPointInLineOfSight, "ElevationManagerDelegate should have been informed of successfully discovery of NearbyPoint in line of sight of current location")
    }
    
    func testNearbyPointNOTInLineOfSightOfCurrentLocationInformsDelegate() {
//        var mockPoint = MockPoint(aName: "Mountain", aLocation: CLLocation())
//        parser.parserError = nil
//        parser.parserPoints = nil
//        mockPoint.parser = parser
//        mockPoint.elevationManagerDelegate = manager
//        mockPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([CLLocation()])
//        XCTAssertFalse(manager.informedOfNearbyPointNOTInLineOfSight, "ElevationManagerDelegate should have been informed of NearbyPoint NOT in line of sight of current location")
    }
    
    func testDeterminingLineOfSightReturnsFalseIfPassedArrayNotOfTypeCLLocation() {
//        var inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([1,2,3])
//        XCTAssertFalse(inLineOfSight, "Passing array NOT of type CLLocation to determine line of sight returns false")
    }
    
    func testDeterminingLineOfSightReturnsFalseIfPassedEmptyArray() {
//        var inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([CLLocation]())
//        XCTAssertFalse(inLineOfSight, "Passing empty array of type CLLocation to determine line of sight returns false")
//        inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([String]())
//        XCTAssertFalse(inLineOfSight, "Passing empty array NOT of type CLLocation to determine line of sight returns false")
    }
    
    func testNearbyPointIsInLineOfSightUpdatesNearbyPointsAltitudeAndRemovesLastElevationProfilePoint() {
//        let inLineOfSight = testPoints.Holts.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([CLLocation(coordinate: CLLocationCoordinate2D(), altitude: 111.1, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: NSDate())])
//        XCTAssertEqual(testPoints.Holts.location.altitude, 111.1, "Determining if NearbyPoint is in line of sight should update its altitude")
//        XCTAssertFalse(inLineOfSight, "NearbyPointIsInLineOfSight should return false because elevationPoints should be empty after removing last time")
    }
    
    func testNearbyPointIsInLineOfSightCallsElevationManagerDelegateToUpdateDistancesAndAnglesForNearbyPoint() {
//        let mockManager = MockNearbyPointsManager(delegate: viewController)
//        testPoints.Holts.elevationManagerDelegate = mockManager
//        let inLineOfSight = testPoints.Holts.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([CLLocation(coordinate: CLLocationCoordinate2D(), altitude: 111.1, horizontalAccuracy: 1.0, verticalAccuracy: 1.0, timestamp: NSDate())])
//        XCTAssertTrue(mockManager.didUpdateDistancesAndAnglesForPoint, "NearbyPoint should call its elevationManagerDelegate to update distances and angles and to add NearbyPoint to nearbyPointsWithAltitude array")
//        XCTAssertFalse(inLineOfSight, "NearbyPointIsInLineOfSight should return false because elevationPoints should be empty after removing last time")
    }

    func testCallToElevationManagerDelegateUpdatesDistancesAndAnglesForNearbyPointCorrectly() {
//        testPoints.Holts.elevationManagerDelegate = manager
//        let Killington = NearbyPoint(aName: "Killington", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(Coordinates.HoltsToKillington.last![0], Coordinates.HoltsToKillington.last![1]), altitude: Altitudes.HoltsToKillington.last!, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
//        let inLineOfSight = testPoints.Holts.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([Killington])
//        XCTAssertEqual(Killington.angleToHorizon, 0.5987909267657717, "NearbyPoint should have correct angleToHorizon")
//        XCTAssertEqual(Killington.angleToCurrentLocation, 0.5987909267657717, "NearbyPoint should have correct angleToHorizon")
//        XCTAssertEqual(Killington.distanceFromCurrentLocation, 0.5987909267657717, "NearbyPoint should have correct angleToHorizon")
    }
    
    func testKillingtonIsInLineOfSightOfHolts() {
        var currentPoint = testPoints.Holts
        manager.currentLocation = currentPoint.location
        var killington = testPoints.Killington
        killington.angleToHorizon = 0.5987909267657717
        
        let altitudes = Altitudes.HoltsToKillington
        
        let coordinates = Coordinates.HoltsToKillington
        
        let elevationProfile = CLLocation.locationArrayFromCoordinates(coordinates, altitudes: altitudes)
//        let inLineOfSight = killington.nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile)
//        XCTAssertTrue(inLineOfSight, "Killington should be in Holt's line of sight")
    }
    
    func testKillingtonIsNotInLineOfSightOfTheSchindlers() {
        var currentPoint = testPoints.Schindlers
        manager.currentLocation = currentPoint.location
        var killington = testPoints.Killington
        killington.angleToHorizon = 1.185378689113316
        
        let altitudes = [180.866455078125,
            405.994781494141,
            468.278137207031,
            242.092498779297,
            393.950714111328,
            469.626434326172,
            571.395263671875,
            440.786560058594,
            569.484680175781,
            1200.83447265625]
        
        let coordinates = [[43.833084,-72.250574],
            [43.807836469372,-72.3140416085183],
            [43.7825538467397,-72.3774555486805],
            [43.7572361927417,-72.4408158388751],
            [43.7318835679707,-72.5041224978059],
            [43.7064960329729,-72.5673755444902],
            [43.6810736482479,-72.6305749982576],
            [43.6556164742485,-72.6937208787479],
            [43.6301245713799,-72.7568132059099],
            [43.604598,-72.819852]]
        
        let elevationProfile = CLLocation.locationArrayFromCoordinates(coordinates, altitudes: altitudes)
//        let inLineOfSight = killington.nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile)
//        XCTAssertFalse(inLineOfSight, "Killington should not be in the Schindler's line of sight")
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

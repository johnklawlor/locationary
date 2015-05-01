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
    static let Point1 = NearbyPoint(aName: "Smarts Mountain", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: 962, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    static let Point2 = NearbyPoint(aName: "Mount Cardigan", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.649675, -71.914211), altitude: 940, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    static let Point3 = NearbyPoint(aName: "Mount Far Away", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(40.12563, -80.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0)))
    
    static let Holts = NearbyPoint(aName: "Holts Ledge", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.772333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let NearHolts = NearbyPoint(aName: "Holts Ledge", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.773333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Smarts = NearbyPoint(aName: "Smarts Mountain", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: 962, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let MooseNorth = NearbyPoint(aName: "Moose Mountain, North", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.741299, -72.136657), altitude: 702, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let MooseSouth = NearbyPoint(aName: "Moose Mountain, South", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.720343, -72.145562), altitude: 694, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Winslow = NearbyPoint(aName: "Winslow", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.776346, -72.077457), altitude: 693, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let BreadLoaf = NearbyPoint(aName: "Bread Loaf", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(44.002280,-72.941500), altitude: 1169, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Schindlers = NearbyPoint(aName: "Schindlers", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.833084, -72.250574), altitude: 187, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Killington = NearbyPoint(aName: "Killington", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.604598, -72.819852), altitude: 1272, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Cardigan = NearbyPoint(aName: "Mount Cardigan", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.649693, -71.914854), altitude: 935, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let Washington = NearbyPoint(aName: "Mount Washington", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(44.270582, -71.303299), altitude: 1908, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
    static let MockHolts = MockPoint(aName: "Holts", aLocation: CLLocation(coordinate: CLLocationCoordinate2DMake(43.772333, -72.107691), altitude: 641, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0)))
}

class NearbyPointClassTests: XCTestCase {

    var point1, point2: NearbyPoint!
    var altitudeCommunicator = AltitudeCommunicator()
    var mockGoogleMapsCommunicator = MockGoogleMapsCommunicator()
    var nnAltitudeCommunicator = MockAltitudeCommunicator()
    var parser = MockParser()
    var parser2 = MockParser()
    var manager: MockNearbyPointsManager!
    var viewController = NearbyPointsViewController()
    var nearbyPoint = TestPoints.Smarts
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name = "Smarts Mountain"
        point1 = NearbyPoint(aName: name, aLocation: location)
        let location2 = CLLocation(coordinate: CLLocationCoordinate2DMake(43.12563, -72.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name2 = "Mount Cardigan"
        point2 = NearbyPoint(aName: name, aLocation: location2)
        
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
        point1.altitudeManagerDelegate = manager
        point1.parser = parser

        parser2.parserPoints = [456]
        point2.altitudeManagerDelegate = manager
        point2.parser = parser2
        
        point1.receivedAltitudeJSON("")
        
        point1.location = CLLocation(coordinate: point1.location.coordinate, altitude: 123, horizontalAccuracy: point1.location.horizontalAccuracy, verticalAccuracy: point1.location.verticalAccuracy, timestamp: point1.location.timestamp)
        point2.location = CLLocation(coordinate: point2.location.coordinate, altitude: 456, horizontalAccuracy: point2.location.horizontalAccuracy, verticalAccuracy: point2.location.verticalAccuracy, timestamp: point2.location.timestamp)
        
        XCTAssertEqual(manager.retrievalCount, 1, "NearbyPoint should inform manager delegate of successfully retrieving altitude")
        
        point2.receivedAltitudeJSON("")

        XCTAssertEqual(manager.retrievalCount, 2, "NearbyPoint should inform manager delegate of successfully retrieving altitude, and add to already assembled nearbyPointsWithAltitude array")
    }
    
    func testTapCallsTapAction() {
        nearbyPoint.label.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertEqual(viewController.nearbyPointCurrentlyDisplayed!, nearbyPoint, "Tapping button should call action")
    }
    
    func testNearbyPointLabelTapInformsDelegate() {
        nearbyPoint.showName(UIButton())
        XCTAssertEqual(viewController.nearbyPointCurrentlyDisplayed!, nearbyPoint, "NearbyPoint's tap delegate should be passed NearbyPoint")
    }
    
    func testCallToDetermineLineOfSightWithNilCommunicatorSetsPrefetchError() {
        nearbyPoint.googleMapsCommunicator = nil
        nearbyPoint.getElevationProfileData()
        XCTAssertEqual(nearbyPoint.prefetchError!, NearbyPointConstants.Error_GoogleMapsCommunicatorNil, "Nil googleMapsCommunicator should set prefetchError")
    }
    
    func testDetermineLineOfSightSetsDelegateAndLocationsWithNonNilGoogleMapsCommunicatorAndFetchesData() {
        nearbyPoint.googleMapsCommunicator = mockGoogleMapsCommunicator
        manager.currentLocation = TestPoints.Holts.location
        nearbyPoint.currentLocationDelegate = manager
        nearbyPoint.getElevationProfileData()
        let googleMapsDelegate = mockGoogleMapsCommunicator.googleMapsCommunicatorDelegate as! NearbyPoint
        XCTAssertEqual(googleMapsDelegate, nearbyPoint, "nearbyPoint should be googleMapsCommunicator's delegate")
        XCTAssertEqual(mockGoogleMapsCommunicator.currentLocation!, TestPoints.Holts.location, "GoogleMapsCommunicator's currentLocation should be equal to NearbyPointsManager's currentLocation")
        XCTAssertEqual(mockGoogleMapsCommunicator.locationOfNearbyPoint!, nearbyPoint.location, "NearbyPoint should set GoogleMapsCommunicator's locationOfNearbyPoint to nearbyPoint's location")
        XCTAssertTrue(mockGoogleMapsCommunicator.askedToFetchJSONData == true, "GoogleMapsCommunicator should have been asked to fetch JSON data")
    }
    
    func testDetermineLineOfSightWithoutCurrentLocationSetPrefetchError() {
        nearbyPoint.googleMapsCommunicator = mockGoogleMapsCommunicator
        manager.currentLocation = nil
        nearbyPoint.currentLocationDelegate = manager
        nearbyPoint.getElevationProfileData()
        XCTAssertEqual(nearbyPoint.prefetchError!, NearbyPointConstants.Error_NoCurrentLocation, "nearbyPoint with a currentLocationDelegate that doesn't have a currentLocation sets a prefetch error")
    }
    
    func testDetermineLineOfSightWithoutALocationSetsPrefetchError() {
        nearbyPoint.googleMapsCommunicator = mockGoogleMapsCommunicator
        manager.currentLocation = TestPoints.Holts.location
        nearbyPoint.currentLocationDelegate = manager
        nearbyPoint.location = nil
        nearbyPoint.getElevationProfileData()
        XCTAssertEqual(nearbyPoint.prefetchError!, NearbyPointConstants.Error_NoNearbyPointLocation, "nearbyPoint with a currentLocationDelegate that doesn't have a location sets a prefetch error")
    }
    
    func testPassingNilToReceivedElevationProfileJSONDataSetsFetchingError() {
        nearbyPoint.receivedElevationProfileJSON(nil)
        XCTAssertEqual(nearbyPoint.fetchingError!, NearbyPointConstants.Error_JSONIsNil, "Nil JSON string should set fetching error")
    }
    
    func testPassingEmptyStringToReceivedElevationProfileJSONDataSetsFetchingError() {
        nearbyPoint.receivedElevationProfileJSON("")
        XCTAssertEqual(nearbyPoint.fetchingError!, NearbyPointConstants.Error_JSONIsEmpty, "Nil JSON string should set fetching error")
    }
    
    func testNearbyPointNotifiesManagerOfParseErrorEvenIfParserReturnsArray() {
        nearbyPoint.elevationManagerDelegate = manager
        parser.parserError = ParserConstants.Error_SerializedJSONPossiblyNotADictionary
        nearbyPoint.parser = parser
        nearbyPoint.receivedElevationProfileJSON("JSON")
        XCTAssertEqual(manager.parsingError!, ParserConstants.Error_SerializedJSONPossiblyNotADictionary, "ElevationManagerDelegate should be passed parsing error")
    }
    
    func testNearbyPointInLineOfSightOfCurrentLocationInformsDelegate() {
        var mockPoint = MockPoint(aName: "Mountain", aLocation: CLLocation())
        parser.parserError = nil
        mockPoint.parser = parser
        parser.parserPoints = [CLLocation()]
        mockPoint.elevationManagerDelegate = manager
        mockPoint.receivedElevationProfileJSON("JSON")
        XCTAssertTrue(manager.informedOfNearbyPointInLineOfSight, "ElevationManagerDelegate should have been informed of successfully discovery of NearbyPoint in line of sight of current location")
    }
    
    func testNearbyPointNOTInLineOfSightOfCurrentLocationDoesNotInformDelegate() {
        var mockPoint = MockPoint(aName: "Mountain", aLocation: CLLocation())
        parser.parserError = nil
        parser.parserPoints = nil
        mockPoint.parser = parser
        mockPoint.elevationManagerDelegate = manager
        mockPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([CLLocation()])
        XCTAssertFalse(manager.informedOfNearbyPointInLineOfSight, "ElevationManagerDelegate should have been informed of successfully discovery of NearbyPoint in line of sight of current location")
    }
    
    func testNearbyPointsIsInLineOfSightGivenNilElevationProfileReturnsFalse() {
        let inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven(nil)
        XCTAssertFalse(inLineOfSight, "Nil elevationProfile should return false in determining if in line of sight")
    }
    
    func testDeterminingLineOfSightReturnsFalseIfPassedArrayNotOfTypeCLLocation() {
        var inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([1,2,3])
        XCTAssertFalse(inLineOfSight, "Passing array NOT of type CLLocation to determine line of sight returns false")
    }
    
    func testDeterminingLineOfSightReturnsFalseIfPassedEmptyArray() {
        var inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([CLLocation]())
        XCTAssertFalse(inLineOfSight, "Passing empty array of type CLLocation to determine line of sight returns false")
        inLineOfSight = nearbyPoint.nearbyPointIsInLineOfSightOfCurrenctLocationGiven([String]())
        XCTAssertFalse(inLineOfSight, "Passing empty array NOT of type CLLocation to determine line of sight returns false")
    }
    
    func testKillingtonIsInLineOfSightOfHolts() {
        var currentPoint = TestPoints.Holts
        manager.currentLocation = currentPoint.location
        var killington = TestPoints.Killington
        killington.angleToHorizon = 0.5987909267657717
        killington.currentLocationDelegate = manager
        
        var elevationProfile = [CLLocation]()
        let altitudes = [614.346008300781,
            317.276916503906,
            118.771034240723,
            317.586242675781,
            220.008392333984,
            395.074798583984,
            357.749359130859,
            460.627288818359,
            661.596984863281,
            1287.99914550781]
        
        let coordinates = [[43.772333,-72.107691],
            [43.7539144376924,-72.1870163156887],
            [43.7354410486442,-72.2662927446971],
            [43.7169129020388,-72.3455202036827],
            [43.6983300671558,-72.4246986099388],
            [43.6796926133706,-72.5038278813945],
            [43.661000610153,-72.5829079366135],
            [43.6422541270662,-72.6619386947941],
            [43.6234532337661,-72.740920075768],
            [43.604598,-72.819852]]
        
        for (index, coordinate) in enumerate(coordinates) {
            let dc = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
            let altitude = altitudes[index]
            elevationProfile.append(CLLocation(coordinate: dc, altitude: altitude, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSince1970: 0)))
        }
        
        let inLineOfSight = killington.nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile)
        XCTAssertTrue(inLineOfSight, "Killington should be in Holt's line of sight")
    }
    
    func testKillingtonIsNotInLineOfSightOfTheSchindlers() {
        var currentPoint = TestPoints.Schindlers
        manager.currentLocation = currentPoint.location
        var killington = TestPoints.Killington
        killington.angleToHorizon = 1.185378689113316
        killington.currentLocationDelegate = manager
        
        var elevationProfile = [CLLocation]()
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
        
        for (index, coordinate) in enumerate(coordinates) {
            let dc = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
            let altitude = altitudes[index]
            elevationProfile.append(CLLocation(coordinate: dc, altitude: altitude, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSince1970: 0)))
        }
        let inLineOfSight = killington.nearbyPointIsInLineOfSightOfCurrenctLocationGiven(elevationProfile)
        XCTAssertFalse(inLineOfSight, "Killington not should be in the Schindler's line of sight")
    }
    
}

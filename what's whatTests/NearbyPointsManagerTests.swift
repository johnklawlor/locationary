//
//  NearbyPointsManagerTests.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class NearbyPointsManagerTests: XCTestCase {

    var manager = NearbyPointsManager()
    var communicator = MockGeonamesCommunicator()
    var locationA = CLLocation(coordinate: CLLocationCoordinate2DMake(43.739442,-72.021706), altitude: 0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
    var managerDelegate = MockNearbyPointsManagerDelegate()
    var parser = MockParser()
    var parserError = NSError(domain: "JSONError", code: 0, userInfo: nil)
    var point1, point2: NearbyPoint!
    var viewController = NearbyPointsViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager.communicator = communicator
        communicator.geonamesCommunicatorDelegate = manager
        manager.managerDelegate = managerDelegate
        manager.parser = parser
        
        manager.currentLocation = locationA
        
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

    func testSettingManagersCurrentLocationSetsCommunicatorsCurrentLocation() {
        XCTAssertEqual(communicator.currentLocation!, locationA, "Current location should be passed to communicator")
    }
    
    func testManagerHasAParser() {
        XCTAssertNotNil(manager.parser!, "Manager should have a parser")
    }
    
    func testManagerAsksCommunicatorToGetGeonamesData() {
        manager.getGeonamesJSONData()
        XCTAssertEqual(communicator.askedToFetchedJSON, true, "Manager should have asked communicator delegate to get JSON data")
    }
    
    func testManagerAttemptsAnotherRequestIfJSONParserReturnsError(){
        parser.parserError = parserError
        manager.receivedNearbyPointsJSON("")
        XCTAssertEqual(manager.communicator!.requestAttempts, 2)
        XCTAssertEqual(communicator.askedToFetchedJSON, true, "Manager should have asked communicator delegate to get JSON data")
    }
    
    func testManagerNotifiesItsDelegateOfFailureToGetJSONDataAfterThreeAttemptsThroughCommunicator() {
        communicator.requestAttempts = 4
        manager.getGeonamesJSONData()
        XCTAssertEqual(communicator.askedToFetchedJSON, false, "Manager should have asked communicator delegate to get JSON data")
        XCTAssertEqual(managerDelegate.failError!, ManagerConstants.Error_ReachedMaxConnectionAttempts, "Manager's delegate should have been informed of max connection attempts error")
        
    }
    
    func testManagerNotifiesItsDelegateOfAssembledNearbyPointsArray() {
        parser.parserPoints = [point1]
        manager.receivedNearbyPointsJSON("Valid JSON")
        XCTAssertTrue(managerDelegate.successfullyAssembledNearbyPointsArray == true, "Manager should notify its delegate of nearbyPoint array")
    }
    
    func testManagerCreatesNewInstanceForEachNearbyPointInNearbyPointsArray() {
        manager.nearbyPoints = [point1, point2]
        manager.getAltitudeJSONDataForEachPoint()
        XCTAssertNotEqual(point1.altitudeCommunicator!, point2.altitudeCommunicator!, "Two points should each have their own instance of AltitudeCommunicator")
    }
    
    func testManagerSetsItselfAsDelegateWhenGetAltitudeData() {
        manager.nearbyPoints = [point1]
        manager.getAltitudeJSONDataForEachPoint()
        XCTAssertTrue(point1.managerDelegate != nil, "Manager should be delegate for NearbyPoint")
    }
    
    func testPointCallsManagerDelegateOnError() {
        point1.managerDelegate = manager
        let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: 404, userInfo: nil)
        point1.fetchingAltitudeFailedWithError(error)
        XCTAssertTrue(manager.fetchingError! == error , "Manager delegate should be informed of AltitudeCommunicator error")
    }
    
    func testAltitudeParserErrorInformsManagerDelegateOfError() {
        point1.parser = parser
        point1.managerDelegate = manager
        parser.parserError = parserError
        point1.receivedAltitudeJSON("")
        XCTAssertEqual(manager.parsingAltitudeError!, parserError, "NearbyPoint should inform manager delegate of parse error. ## We might do something with this parse error later, such as remove this point from the nearbyPoints array, or make a request to another web service for the altitude")
    }
    
    func testManagerInformsDelegateOfSuccessfulAltitudeRetrievalAndPassesNearbyPoint() {
        viewController.nearbyPointsWithAltitude = [NearbyPoint]()
        manager.managerDelegate = viewController
        manager.successfullyRetrievedAltitude(TestPoints.Point1)
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [TestPoints.Point1], "Manager should pass NearbyPoint with altitude to its delegate")
        manager.successfullyRetrievedAltitude(TestPoints.Point2)
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [TestPoints.Point1, TestPoints.Point2], "Manager should pass NearbyPoint with altitude to its delegate")
    }

}
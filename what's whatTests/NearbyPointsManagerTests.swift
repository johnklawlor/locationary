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
import CoreMotion

struct Location {
    static let One = CLLocation(coordinate: CLLocationCoordinate2DMake(43.739442,-72.021706), altitude: 0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
}

class NearbyPointsManagerTests: XCTestCase {

    var manager: NearbyPointsManager!
    var communicator = MockGeonamesCommunicator()
    var managerDelegate = MockNearbyPointsManagerDelegate()
    var parser = MockParser()
    var parserError = NSError(domain: "JSONError", code: 0, userInfo: nil)
    var point1, point2: NearbyPoint!
    var viewController = NearbyPointsViewController()
    var mockManager: MockNearbyPointsManager!
    
    var testPoints = TestPoints()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = NearbyPointsManager(delegate: viewController)
        mockManager = MockNearbyPointsManager(delegate: viewController)
        manager.communicator = communicator
        communicator.geonamesCommunicatorDelegate = manager
        manager.parser = parser
        viewController.locationManager = CLLocationManager()
        viewController.motionManager = CMMotionManager()
        
        manager.currentLocation = Location.One
        
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
        XCTAssertEqual(communicator.currentLocation!, Location.One, "Current location should be passed to communicator")
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
        manager.managerDelegate = managerDelegate
        manager.getGeonamesJSONData()
        XCTAssertEqual(communicator.askedToFetchedJSON, false, "Manager should have asked communicator delegate to get JSON data")
        XCTAssertEqual(managerDelegate.failError!, ManagerConstants.Error_ReachedMaxConnectionAttempts, "Manager's delegate should have been informed of max connection attempts error")
        
    }
    
    func testManagerSetsNearbyPointsArrayAndNotifiesItsDelegateOfAssembledNearbyPointsArray() {
        manager.managerDelegate = managerDelegate 
        parser.parserPoints = [testPoints.Holts]
        manager.receivedNearbyPointsJSON("Valid JSON")
        XCTAssertEqual(manager.nearbyPoints!, [testPoints.Holts], "Manager should set its nearbyPoints array after successfully parsing JSON")
        XCTAssertTrue(managerDelegate.successfullyAssembledNearbyPointsArray == true, "Manager should notify its delegate of nearbyPoint array")
    }
    
    func testManagerSetsViewControllerToBeNearbyPointsLabelTapDelegate() {
        manager.getElevationProfileDataForPoint(testPoints.MockHolts)
        let nearbyPointsVC = testPoints.MockHolts.labelTapDelegate as! NearbyPointsViewController
        XCTAssertEqual(nearbyPointsVC, viewController, "Manager's delegate viewController should be NearbyPoint's tap delegate")
    }
    
//    func testManagerAsksNearbyPointToGetJSONData() {
//        manager.nearbyPoints = [testPoints.MockHolts]
//        manager.getAltitudeJSONDataForEachPoint()
//        XCTAssertTrue(testPoints.MockHolts.askedToGetJSONData, "NearbyPoint should have been asked to get JSON Data")
//    }
    
//    func testPointCallsManagerDelegateOnError() {
//        point1.altitudeManagerDelegate = manager
//        let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: 404, userInfo: nil)
//        point1.fetchingAltitudeFailedWithError(error)
//        XCTAssertTrue(manager.fetchingError! == error , "Manager delegate should be informed of AltitudeCommunicator error")
//    }
    
//    func testAltitudeParserErrorInformsManagerDelegateOfError() {
//        point1.parser = parser
//        point1.altitudeManagerDelegate = manager
//        parser.parserError = parserError
//        point1.receivedAltitudeJSON("")
//        XCTAssertEqual(manager.parsingError!, parserError, "NearbyPoint should inform manager delegate of parse error. ## We might do something with this parse error later, such as remove this point from the nearbyPoints array, or make a request to another web service for the altitude")
//    }
    
//    func testManagerGetsElevationProfileDataAfterSuccessfullyRetrievingAltitude() {
//        manager.managerDelegate = managerDelegate
//        manager.nearbyPointsWithAltitude = [NearbyPoint]()
//        manager.successfullyRetrievedAltitude(testPoints.Holts)
//        XCTAssertEqual(managerDelegate.retrievedPoint!, testPoints.Holts, "Manager should pass NearbyPoint with altitude and updated distances to its delegate")
//    }
    
//    func testManagerAddsNearbyPointToItsOwnArrayAfterSuccessfullyRetrievingAltitude() {
//        manager.nearbyPointsWithAltitude = [NearbyPoint]()
//        manager.successfullyRetrievedAltitude(testPoints.Point1)
//        XCTAssertEqual(manager.nearbyPointsWithAltitude!, [testPoints.Point1], "Manager should add NearbyPoint to its nearbyPointsWithAltitude array after successfully retrieving altitude")
//        manager.successfullyRetrievedAltitude(testPoints.Point2)
//        XCTAssertEqual(manager.nearbyPointsWithAltitude!, [testPoints.Point1, testPoints.Point2], "Manager should add second NearbyPoint to its nearbyPointsWithAltitude array after successfully retrieving altitude")
//    }
    
//    func testManagerDoesNotInformDelegateIfNearbyPointIsOutOfDistanceBounds() {
//        viewController.nearbyPointsInLineOfSight = [NearbyPoint]()
//        manager.managerDelegate = viewController
//        manager.upperDistanceLimit = 5000
//        manager.successfullyRetrievedAltitude(testPoints.Point1)
//        XCTAssertTrue(viewController.nearbyPointsInLineOfSight?.isEmpty == true, "nearbyPoint should not have been passed to delegate")
//    }
    
    func testManagerUpdatesDistancesCorrectly() {
        
//        manager.currentLocation = testPoints.NearHolts.location
//        manager.nearbyPointsWithAltitude = [testPoints.Point1, testPoints.Point2]
//        manager.updateDistanceOfNearbyPointsWithAltitude()
//
//        let distance1 = testPoints.Point1.distanceFromCurrentLocation
//        let angle1 = testPoints.Point1.angleToCurrentLocation
//        let horizonAngle1 = testPoints.Point1.angleToHorizon
//        let distance2 = testPoints.Point2.distanceFromCurrentLocation
//        let angle2 = testPoints.Point2.angleToCurrentLocation
//        let horizonAngle2 = testPoints.Point2.angleToHorizon
//        
//        XCTAssertEqual(distance1.format(), "8401.083881", "viewController should have updated Point1's distanceToCurrentLocation")
//        XCTAssertEqual(distance2.format(), "20784.699292", "viewController should have updated Point2's distanceToCurrentLocation")
//        XCTAssertEqual(angle1.format(), "43.769368", "viewController should have updated Point1's distanceToCurrentLocation")
//        XCTAssertEqual(angle2.format(), "318.614398", "viewController should have updated Point2's distanceToCurrentLocation")
//        XCTAssertEqual(horizonAngle1.format(), "3.871676", "viewController should have updated Point1's distanceToCurrentLocation")
//        XCTAssertEqual(horizonAngle2.format(), "0.398280", "viewController should have updated Point2's distanceToCurrentLocation")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForUpperLeftQuadrant() {
        manager.currentLocation = testPoints.Schindlers.location
        testPoints.BreadLoaf.distanceFromCurrentLocation = 79642.5353450668
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(testPoints.BreadLoaf)
        
        XCTAssertEqual(testPoints.BreadLoaf.angleToCurrentLocation.format(), "166.344027", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForLowerLeftQuadrant() {
        manager.currentLocation = testPoints.Schindlers.location
        testPoints.Killington.distanceFromCurrentLocation = 52436.45053701883
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(testPoints.Killington)
        
        XCTAssertEqual(testPoints.Killington.angleToCurrentLocation.format(), "208.962171", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForLowerRightQuadrant() {
        manager.currentLocation = testPoints.Schindlers.location
        testPoints.Cardigan.distanceFromCurrentLocation = 33863.50043960952
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(testPoints.Cardigan)
        
        XCTAssertEqual(testPoints.Cardigan.angleToCurrentLocation.format(), "323.001083", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForUpperRightQuadrant() {
        manager.currentLocation = testPoints.Schindlers.location
        testPoints.Washington.distanceFromCurrentLocation = 90156.9704688527
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(testPoints.Washington)
        
        XCTAssertEqual(testPoints.Washington.angleToCurrentLocation.format(), "32.639578", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerInformsDelegateAfterItUpdatesDistances() {
//        manager.managerDelegate = managerDelegate
//        manager.nearbyPointsWithAltitude = [testPoints.Point1]
//        manager.updateDistanceOfNearbyPointsWithAltitude()
//        XCTAssertEqual(managerDelegate.updatedNearbyPoints, [testPoints.Point1], "Manager should call its delegate after it updates distances and angle")
    }
    
    func testCallingDeterminePointsInLineOfSightWithNearbyPointsAsNilSetsPrefetchError() {
        manager.nearbyPoints = nil
        manager.determineIfEachPointIsInLineOfSight()
        XCTAssertEqual(manager.prefetchError!, ManagerConstants.Error_NearbyPointsIsNil, "If NearbyPoints is nil, calling determineLineOfSight should set prefetchError")
    }
    
    func testDeterminePointsInLineOfSightWithNonNilNearbyPointsArrayInitializesNearbyPointsInLineOfSightArray() {
        manager.nearbyPoints = [NearbyPoint]()
        manager.determineIfEachPointIsInLineOfSight()
//        XCTAssertNotNil(manager.nearbyPointsWithAltitude, "DeterminePointsInLineOfSight initializes nearbyPointsInLineOfSight array when nearbyPoints is non-nil")
//        XCTAssertTrue(manager.nearbyPointsWithAltitude?.isEmpty == true, "nearbyPointsInLineOfSight should be empty")
    }
    
    func testManagerCallsNearbyPointsDetermineIfInLightOfSight() {
        let mockPoint = MockPoint(aName: "mock", aLocation: CLLocation())
        manager.nearbyPoints = [mockPoint]
        manager.determineIfEachPointIsInLineOfSight()
//        XCTAssertTrue(mockPoint.askedToDetermineIfInLineOfSight == true, "nearbyPoint should have been asked to determine if point is in line of sight")
    }
    
    func testManagerInformsDelegateOfPointInLineOfSightOfCurrentLocation() {
//        let anotherManager = AnotherMockManager(delegate: viewController)
//        anotherManager.managerDelegate = managerDelegate
//        anotherManager.currentLocationCanViewNearbyPoint(testPoints.Holts)
//    XCTAssertTrue(anotherManager.didUpdateDistancesAndAnglesForPoint, "Manager should make call to update distances and angles")
//        XCTAssertEqual(managerDelegate.retrievedPoint!, testPoints.Holts, "NearbyPointsManager delegate should be passed NearbyPoint that's in line of sight of current location")
    }

}
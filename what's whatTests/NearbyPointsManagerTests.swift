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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = NearbyPointsManager(delegate: viewController)
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
        manager.getGeonamesJSONData()
        manager.managerDelegate = managerDelegate
        XCTAssertEqual(communicator.askedToFetchedJSON, false, "Manager should have asked communicator delegate to get JSON data")
        XCTAssertEqual(managerDelegate.failError!, ManagerConstants.Error_ReachedMaxConnectionAttempts, "Manager's delegate should have been informed of max connection attempts error")
        
    }
    
    func testManagerNotifiesItsDelegateOfAssembledNearbyPointsArray() {
        manager.managerDelegate = managerDelegate
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
        manager.nearbyPoints = [TestPoints.MockHolts]
        manager.getAltitudeJSONDataForEachPoint()
        let theManager = TestPoints.MockHolts.altitudeManagerDelegate as! NearbyPointsManager
        XCTAssertEqual(manager, theManager, "Manager should be delegate for NearbyPoint")
    }
    
    func testManagerSetsViewControllerToBeNearbyPointsLabelTapDelegate() {
        manager.nearbyPoints = [TestPoints.MockHolts]
        manager.getAltitudeJSONDataForEachPoint()
        let nearbyPointsVC = TestPoints.MockHolts.labelTapDelegate as! NearbyPointsViewController
        XCTAssertEqual(nearbyPointsVC, viewController, "Manager's delegate viewController should be NearbyPoint's tap delegate")
    }
    
    func testManagerSetsItsParserToBeNearbyPointsParser() {
        TestPoints.MockHolts.parser = nil
        manager.nearbyPoints = [TestPoints.MockHolts]
        manager.getAltitudeJSONDataForEachPoint()
        XCTAssertEqual(manager.parser, TestPoints.MockHolts.parser, "Manager should sets its parser to be NearbyPoint's parser")
    }
    
    func testManagerAsksNearbyPointToGetJSONData() {
        manager.nearbyPoints = [TestPoints.MockHolts]
        manager.getAltitudeJSONDataForEachPoint()
        XCTAssertTrue(TestPoints.MockHolts.askedToGetJSONData, "NearbyPoint should have been asked to get JSON Data")
    }
    
    func testPointCallsManagerDelegateOnError() {
        point1.altitudeManagerDelegate = manager
        let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: 404, userInfo: nil)
        point1.fetchingAltitudeFailedWithError(error)
        XCTAssertTrue(manager.fetchingError! == error , "Manager delegate should be informed of AltitudeCommunicator error")
    }
    
    func testAltitudeParserErrorInformsManagerDelegateOfError() {
        point1.parser = parser
        point1.altitudeManagerDelegate = manager
        parser.parserError = parserError
        point1.receivedAltitudeJSON("")
        XCTAssertEqual(manager.parsingError!, parserError, "NearbyPoint should inform manager delegate of parse error. ## We might do something with this parse error later, such as remove this point from the nearbyPoints array, or make a request to another web service for the altitude")
    }
    
    func testManagerGetsElevationProfileDataAfterSuccessfullyRetrievingAltitude() {
        manager.managerDelegate = managerDelegate
        manager.nearbyPointsWithAltitude = [NearbyPoint]()
        manager.successfullyRetrievedAltitude(TestPoints.Holts)
        XCTAssertEqual(managerDelegate.retrievedPoint!, TestPoints.Holts, "Manager should pass NearbyPoint with altitude and updated distances to its delegate")
    }
    
    func testManagerAddsDistanceFromCurrentLocationToNearbyPointBeforeNotifiyingDelegate() {
        manager.successfullyRetrievedAltitude(TestPoints.Point1)
        XCTAssertEqual(TestPoints.Point1.distanceFromCurrentLocation, 9614.14541222178, "nearbyPoint's distanceFromCurrentLocation should get updated after successfully retrieving altitude")
    }
    
    func testManagerAddsAngleToCurrentLocationAfterSuccessfullyRetrievingAltitude() {
        TestPoints.Point1.angleToCurrentLocation = nil
        manager.successfullyRetrievedAltitude(TestPoints.Point1)
        XCTAssertNotNil(TestPoints.Point1.angleToCurrentLocation, "Manager should update nearbyPoint's angleToCurrentLocation")
    }
    
    func testManagerAddsAngleToHorizonAfterSuccessfullyRetrievingAltitude() {
        manager.currentLocation = TestPoints.Holts.location
        manager.successfullyRetrievedAltitude(TestPoints.Winslow)
        XCTAssertEqual(TestPoints.Winslow.angleToHorizon.format(), "2.258537", "Manager should update nearbyPoint's angleToCurrentLocation")
    }
    
    func testManagerInitializesNearbyPointsWithAltitudeArrayBeforeGettingAltitudeData() {
        manager.nearbyPoints = [TestPoints.Point1]
        manager.getAltitudeJSONDataForEachPoint()
        XCTAssertEqual(manager.nearbyPointsWithAltitude!, [NearbyPoint](), "Calling manager's getAltitudeJSONDataForEachPoint should initialize nearbyPointsWithAltitude array")
    }
    
    func testManagerAddsNearbyPointToItsOwnArrayAfterSuccessfullyRetrievingAltitude() {
        manager.nearbyPointsWithAltitude = [NearbyPoint]()
        manager.successfullyRetrievedAltitude(TestPoints.Point1)
        XCTAssertEqual(manager.nearbyPointsWithAltitude!, [TestPoints.Point1], "Manager should add NearbyPoint to its nearbyPointsWithAltitude array after successfully retrieving altitude")
        manager.successfullyRetrievedAltitude(TestPoints.Point2)
        XCTAssertEqual(manager.nearbyPointsWithAltitude!, [TestPoints.Point1, TestPoints.Point2], "Manager should add second NearbyPoint to its nearbyPointsWithAltitude array after successfully retrieving altitude")
    }
    
//    func testManagerDoesNotInformDelegateIfNearbyPointIsOutOfDistanceBounds() {
//        viewController.nearbyPointsInLineOfSight = [NearbyPoint]()
//        manager.managerDelegate = viewController
//        manager.upperDistanceLimit = 5000
//        manager.successfullyRetrievedAltitude(TestPoints.Point1)
//        XCTAssertTrue(viewController.nearbyPointsInLineOfSight?.isEmpty == true, "nearbyPoint should not have been passed to delegate")
//    }
    
    func testManagerPassesUpdatedArrayToItsDelegate() {
        manager.managerDelegate.updatedNearbyPointsWithAltitudeAndUpdatedDistance([TestPoints.Point1, TestPoints.Point2])
        XCTAssertEqual(managerDelegate.updatedNearbyPoints, [TestPoints.Point1, TestPoints.Point2], "Manager delegate should have been passed Point1 and Point2 as array")
    }
    
    func testManagerUpdatesDistancesCorrectly() {
        
        manager.currentLocation = TestPoints.NearHolts.location
        manager.nearbyPointsWithAltitude = [TestPoints.Point1, TestPoints.Point2]
        manager.updateDistanceOfNearbyPointsWithAltitude()

        let distance1 = TestPoints.Point1.distanceFromCurrentLocation
        let angle1 = TestPoints.Point1.angleToCurrentLocation
        let horizonAngle1 = TestPoints.Point1.angleToHorizon
        let distance2 = TestPoints.Point2.distanceFromCurrentLocation
        let angle2 = TestPoints.Point2.angleToCurrentLocation
        let horizonAngle2 = TestPoints.Point2.angleToHorizon
        
        XCTAssertEqual(distance1.format(), "8401.083881", "viewController should have updated Point1's distanceToCurrentLocation")
        XCTAssertEqual(distance2.format(), "20784.699292", "viewController should have updated Point2's distanceToCurrentLocation")
        XCTAssertEqual(angle1.format(), "43.769368", "viewController should have updated Point1's distanceToCurrentLocation")
        XCTAssertEqual(angle2.format(), "318.614398", "viewController should have updated Point2's distanceToCurrentLocation")
        XCTAssertEqual(horizonAngle1.format(), "3.871676", "viewController should have updated Point1's distanceToCurrentLocation")
        XCTAssertEqual(horizonAngle2.format(), "0.398280", "viewController should have updated Point2's distanceToCurrentLocation")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForUpperLeftQuadrant() {
        manager.currentLocation = TestPoints.Schindlers.location
        TestPoints.BreadLoaf.distanceFromCurrentLocation = 79642.5353450668
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(TestPoints.BreadLoaf)
        
        XCTAssertEqual(TestPoints.BreadLoaf.angleToCurrentLocation.format(), "166.344027", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForLowerLeftQuadrant() {
        manager.currentLocation = TestPoints.Schindlers.location
        TestPoints.Killington.distanceFromCurrentLocation = 52436.45053701883
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(TestPoints.Killington)
        
        XCTAssertEqual(TestPoints.Killington.angleToCurrentLocation.format(), "208.962171", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForLowerRightQuadrant() {
        manager.currentLocation = TestPoints.Schindlers.location
        TestPoints.Cardigan.distanceFromCurrentLocation = 33863.50043960952
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(TestPoints.Cardigan)
        
        XCTAssertEqual(TestPoints.Cardigan.angleToCurrentLocation.format(), "323.001083", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerUpdatesAngleToCurrentLocationCorrectlyForUpperRightQuadrant() {
        manager.currentLocation = TestPoints.Schindlers.location
        TestPoints.Washington.distanceFromCurrentLocation = 90156.9704688527
        
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(TestPoints.Washington)
        
        XCTAssertEqual(TestPoints.Washington.angleToCurrentLocation.format(), "32.639578", "calculateAbsoluteAngleWithCurrentLocationAsOrigin should return correct value")
    }
    
    func testManagerInformsDelegateAfterItUpdatesDistances() {
        manager.nearbyPointsWithAltitude = [TestPoints.Point1]
        manager.updateDistanceOfNearbyPointsWithAltitude()
        XCTAssertEqual(managerDelegate.updatedNearbyPoints, [TestPoints.Point1], "Manager should call its delegate after it updates distances and angle")
    }
    
    func testCallingDeterminePointsInLineOfSightWithNearbyPointsAsNilSetsPrefetchError() {
        manager.nearbyPoints = nil
        manager.determineIfEachPointIsInLineOfSight()
        XCTAssertEqual(manager.prefetchError!, ManagerConstants.Error_NearbyPointsIsNil, "If NearbyPoints is nil, calling determineLineOfSight should set prefetchError")
    }
    
    func testDeterminePointsInLineOfSightWithNonNilNearbyPointsArrayInitializesNearbyPointsInLineOfSightArray() {
        manager.nearbyPoints = [NearbyPoint]()
        manager.determineIfEachPointIsInLineOfSight()
        XCTAssertNotNil(manager.nearbyPointsWithAltitude, "DeterminePointsInLineOfSight initializes nearbyPointsInLineOfSight array when nearbyPoints is non-nil")
        XCTAssertTrue(manager.nearbyPointsWithAltitude?.isEmpty == true, "nearbyPointsInLineOfSight should be empty")
    }
    
    func testManagerIsDelegateForNearbyPointAndHasAGoogleMapsCommunicatorAndParserAfterCallToDetermineLineOfSight() {
        let point = TestPoints.Holts
        manager.nearbyPoints = [point]
        manager.determineIfEachPointIsInLineOfSight()
        let managerDelegate = point.altitudeManagerDelegate as! NearbyPointsManager
        XCTAssertEqual(managerDelegate, manager, "Manager should be nearbyPoint's delegate")
        XCTAssertNotNil(point.googleMapsCommunicator, "Point should have a GoogleMapsCommunicator")
        XCTAssertEqual(manager.parser, point.parser, "nearbyPoint should have manager's parser")
        
        let currentLocationDelegate = point.currentLocationDelegate as? NearbyPointsManager
        XCTAssertEqual(currentLocationDelegate!, manager, "nearbyPointsManager should be point's currentLocationDelegate")
    }
    
    func testManagerCallsNearbyPointsDetermineIfInLightOfSight() {
        let mockPoint = MockPoint(aName: "mock", aLocation: CLLocation())
        manager.nearbyPoints = [mockPoint]
        manager.determineIfEachPointIsInLineOfSight()
        XCTAssertTrue(mockPoint.askedToDetermineIfInLineOfSight == true, "nearbyPoint should have been asked to determine if point is in line of sight")
    }
    
    func testManagerAppendsToNearbyPointsWithAltitudeArrayWhenNearbyPointInformsManagerOfPointInLineOfSightOfCurrentLocation() {
        manager.nearbyPointsWithAltitude = [NearbyPoint]()
        manager.currentLocationCanViewNearbyPoint(TestPoints.Holts)
        XCTAssertEqual(manager.nearbyPointsWithAltitude!, [TestPoints.Holts], "Manager should append NearbyPoint to nearbyPointsWithAltitude when NearbyPoint informs it that the nearby point is in line of sight of the current location")
    }

}
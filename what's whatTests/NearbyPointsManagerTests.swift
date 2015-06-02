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
    var mockElevationDataManager = MockElevationDataManager()
    
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
    
    
    
    func testManagerUpdatesDistancesCorrectly() {
        
        manager.currentLocation = testPoints.NearHolts.location
        manager.calculateDistanceFromCurrentLocation(testPoints.Point1)
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(testPoints.Point1)
        manager.calculateDistanceFromCurrentLocation(testPoints.Point2)
        manager.calculateAbsoluteAngleWithCurrentLocationAsOrigin(testPoints.Point2)

        let distance1 = testPoints.Point1.distanceFromCurrentLocation
        let angle1 = testPoints.Point1.angleToCurrentLocation

        let distance2 = testPoints.Point2.distanceFromCurrentLocation
        let angle2 = testPoints.Point2.angleToCurrentLocation

        
        XCTAssertEqual(distance1.format(), "8401.083881", "Manager should have updated Point1's distanceToCurrentLocation")
        XCTAssertEqual(distance2.format(), "20784.699292", "Manager should have updated Point2's distanceToCurrentLocation")
        XCTAssertEqual(angle1.format(), "43.769368", "Manager should have updated Point1's distanceToCurrentLocation")
        XCTAssertEqual(angle2.format(), "318.614398", "Manager should have updated Point2's distanceToCurrentLocation")

//        manager.currentLocation = testPoints.NearHolts.location
//        
//        let horizonAngle1 = testPoints.Point1.angleToHorizon
//        let horizonAngle2 = testPoints.Point2.angleToHorizon
//        
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
    
    func testCallingDeterminePointsInLineOfSightWithNearbyPointsAsNilSetsPrefetchError() {
        manager.nearbyPoints = nil
        manager.determineIfEachPointIsInLineOfSight()
        XCTAssertEqual(manager.prefetchError!, ManagerConstants.Error_NearbyPointsIsNil, "If NearbyPoints is nil, calling determineLineOfSight should set prefetchError")
    }
    
    func testCallingDeterminePointsInLineOfSightWithNonNilNearbyPointsCallsElevationDataManager() {
        manager.nearbyPoints = [testPoints.Holts]
        manager.elevationDataManager = mockElevationDataManager
        manager.determineIfEachPointIsInLineOfSight()
        
        XCTAssertTrue(mockElevationDataManager.askedToGetElevationData, "Call to determineIfEachPointIsInLineOfSight creates an ElevationDataManager")
    }
    
    func testBadElevationDataRemovesPointFromNearbyPointsArray() {
        manager.nearbyPoints = [testPoints.Holts]
        let elevationData = ElevationData(anElevation: 32678, anAngleToHorizon: 0, IsInLineOfSight: false)
        manager.processElevationProfileDataForPoint(testPoints.Holts, elevationData: elevationData)
        XCTAssertTrue(manager.nearbyPoints!.isEmpty, "Processing non-existent elevation data should remove the point from the NearbyPoints array")
    }
    
    func testProcessingElevationDataUpdatesNearbyPointsDistanceAndElevationWhenInLineOfSight() {
        mockManager.nearbyPoints = [testPoints.Holts]
        let elevationData = ElevationData(anElevation: 200, anAngleToHorizon: 0, IsInLineOfSight: true)
        mockManager.processElevationProfileDataForPoint(testPoints.Holts, elevationData: elevationData)
        XCTAssertTrue(mockManager.askedToCalculateDistance, "Manager should make call to update distance to currentLocation")
        XCTAssertTrue(mockManager.askedToUpdateElevationAndAngleToHorizon, "Manager should make call to update elevation it received from ElevationDataManager")
        XCTAssertTrue(mockManager.askedToCalculateAbsoluteAngleWithCurrentLocationAsOrigin, "Manager should make ")
    }
    
    func testCallToUpdateElevationAndAngleToHorizonActuallyDoesSo() {
        manager.updateElevationAndAngleToHorizonForPoint(testPoints.Holts, elevation: 200.0, angleToHorizon: 5.0)
        XCTAssertEqual(testPoints.Holts.location.altitude, 200.0, "Altitude should have been updated")
        XCTAssertEqual(testPoints.Holts.angleToHorizon, 5.0, "Angle to horizon should have been updated")
    }
    
    func testProcessingDataCreatesButtonAndSetsTapDelegateWhenInLineOfSight() {
        mockManager.nearbyPoints = [testPoints.Holts]
        let elevationData = ElevationData(anElevation: 200, anAngleToHorizon: 0, IsInLineOfSight: true)
        mockManager.processElevationProfileDataForPoint(testPoints.Holts, elevationData: elevationData)
        
        let button = testPoints.Holts.label as UIButton
        let delegate = testPoints.Holts.labelTapDelegate as! NearbyPointsViewController
        
        XCTAssertNotNil(button, "NearbyPoint should have its label initialized as a UIButton")
        XCTAssertEqual(viewController, delegate, "ViewController should be NearbyPoint's labelTapDelegate")
    }
    
    func testProcessingDataInformsTheDelegateOfTheNearbyPointsManagerOfSuccessfullyFindingAPointInLineOfSight() {
        var mockViewController = MockNearbyPointsViewController()
        mockManager = MockNearbyPointsManager(delegate: mockViewController)
        mockManager.nearbyPoints = [testPoints.Holts]
        let elevationData = ElevationData(anElevation: 200, anAngleToHorizon: 0, IsInLineOfSight: true)
        mockManager.processElevationProfileDataForPoint(testPoints.Holts, elevationData: elevationData)
        XCTAssertTrue(mockViewController.informedOfSuccessfullyFindingNearbyPointInLineOfSight, "NearbyPointsManager should inform its delegate when it successfully finds a NearbyPoint in line of sight")
    }

}
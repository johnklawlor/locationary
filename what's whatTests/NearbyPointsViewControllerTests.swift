//
//  NearbyPointsViewController.swift
//  what's what
//
//  Created by John Lawlor on 4/2/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class NearbyPointsViewControllerTests: XCTestCase {

    var viewController = NearbyPointsViewController()
    var manager: NearbyPointsManager! = NearbyPointsManager()
    var locationManager = CLLocationManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController.locationManager = locationManager
        viewController.locationManager(locationManager, didUpdateLocations: [Location.One])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSettingViewControllersCurrentLocationCreatesANearbyPointsManager() {
        XCTAssertNotNil(viewController.nearbyPointsManager!, "Nearby Points View Controller should have a Nearby Points manager")
    }
    
    func testSettingViewControllersCurrentLocationSetNearbyPointsManagerToSelf() {
        let delegateVC = viewController.nearbyPointsManager!.managerDelegate! as! NearbyPointsViewController
        XCTAssertEqual(viewController, delegateVC, "ViewController should be nearbyPointsManager's delegate")
    }
    
    func testViewControllerInitialesNearbyPointsWithAltitudeWhenNilCurrentLocationIsSet() {
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [NearbyPoint](), "Setting viewController's currentLocation when nil initializes an empty nearbyPointsWithAltitude array")
    }

    func testViewControllerDoesNotRenitialesNearbyPointsWithAltitudeArrayWhenCurrentLocationIsSet() {
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        viewController.nearbyPointsWithAltitude = [TestPoints.Point1]
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [TestPoints.Point1], "Resetting viewController's currentLocation is less than 1000 away from new value of currentLocation does not initialize an empty nearbyPointsWithAltitude array")
    }
    
    func testViewControllerReinitializesNearbyPointsWithAltitudeArrayWhenCurrentIsSetAndDistanceToNewCurrentLocationValueIsGreaterThan1000(){
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        viewController.nearbyPointsWithAltitude = [TestPoints.Point1]
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point3.location])
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [NearbyPoint](), "Resetting viewController's currentLocation is less than 1000 away from new value of currentLocation does not initialize an empty nearbyPointsWithAltitude array")
    }
    
    func testSettingNewNearbyPointsManagerStopsAppendingOfOldNearbyPointsWithAltitude() {
        let point1 = TestPoints.Point1
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Holts.location])
        point1.managerDelegate = viewController.nearbyPointsManager
        point1.managerDelegate!.successfullyRetrievedAltitude(point1)
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [point1], "viewController should have received the NearbyPoint and appended it to nearbyPointsWithAltitude")

        let point2 = TestPoints.Point2
        point2.managerDelegate = point1.managerDelegate
        let point3 = TestPoints.Point3
        viewController.locationManager(locationManager, didUpdateLocations: [point3.location])
        point2.managerDelegate?.successfullyRetrievedAltitude(point2)
        XCTAssertEqual(viewController.nearbyPointsManager.currentLocation!, point3.location, "viewController should update its currentLocation")
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [NearbyPoint](), "viewController should NOT have received the NearbyPoint and appended it to nearbyPointsWithAltitude")
    }
    
    func testUpdatingLocationToLessThan1000MetersFromOldLocationRecalculatesAngleAndDistanceInNearbyPointsWithAltitude() {
        let mockManager = MockNearbyPointsManager()
        mockManager.currentLocation = TestPoints.Holts.location
        viewController.nearbyPointsManager = mockManager
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.NearHolts.location])
        XCTAssertEqual(mockManager.updatedDistances, true, "ViewController should have called its nearbyPointsManager to update distances and angles for the new location")
    }
    
    func testUpdatingHeadingConvertsCurrentHeadingToAngleWhichIsZeroAtThePositiveXAxisAndIncrementsCounterClockwise() {
        var heading = MockHeading(heading: 45.0)
        var newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading, heading.trueHeading, "Both headings should match")
        heading = MockHeading(heading: 0.1)
        newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading, CLLocationDirection(89.9), "Both headings should match")
        heading = MockHeading(heading: 180.0)
        newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading, CLLocationDirection(270.0), "Both headings should match")
        heading = MockHeading(heading: 255.0)
        newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading, CLLocationDirection(195.0), "Both headings should match")
    }
    
    func testViewControllerGetsPointsWithinFieldOfVisionOfCamera() {
//        viewController.DeviceConstants = Constants(hfov: 58, vfoc: 32, phoneWidth: 650, phoneHeight: 376)
//        viewController.nearbyPointsToShow = [Int]()
//        viewController.nearbyPointsWithAltitude = [TestPoints.Holts, TestPoints.Smarts, TestPoints.Winslow]
//        viewController.currentHeading = 30.0
//        viewController.getIndicesOfPointsWithinFieldOfVisionOfCamera()
//        XCTAssertEqual(viewController.nearbyPointsToShow!, [1,2], "nearbyPointsToShow should contain the first two indices of nearbyPointsWithAltitude because iPhone is pointed in their direction")
        
    }
    
    func testViewDidLoadCreatesEmptyNearbyPointsSubviews() {
        viewController.viewDidLoad()
        XCTAssertTrue(viewController.nearbyPointsSubviews != nil, "nearbyPointsSubviews should be initialized and empty")
    }
    
    func testSettingLocationManagerCreatesItsConfiguration() {
        viewController.locationManager = locationManager
        XCTAssertEqual(locationManager.distanceFilter, kCLDistanceFilterNone, "Distance filter should be set to none")
        XCTAssertEqual(locationManager.desiredAccuracy, kCLLocationAccuracyBest, "Accuray should be set to best")
    }

    func testViewDidLoadStartsLocationManagerUpdates() {
        class MockLocationManager: CLLocationManager {
            var didStartUpdatingLocation: Bool! = false
            override func startUpdatingLocation() {
                didStartUpdatingLocation = true
            }
        }
        viewController.locationManager = MockLocationManager()
        viewController.viewDidLoad()
        let mockLocationManager = viewController.locationManager as! MockLocationManager
        XCTAssertEqual(mockLocationManager.didStartUpdatingLocation, true, "ViewDidLoad should start updating location")
    }
    
    func testUpdatingLocationForFirstTimeGetGeonmaesJSONData() {
        let mockViewController = MockNearbyPointsViewController()
        mockViewController.locationManager(locationManager, didUpdateLocations: [Location.One])
        let mockNearbyPointsManager = mockViewController.nearbyPointsManager as! MockNearbyPointsManager
        XCTAssertEqual(mockNearbyPointsManager.askedToGetGeonamesJSONData, true, "ViewController without a nearbyPointsManager should create one and call getGeonamesJSONData")
    }
    
    func testUpdatingLocationGreaterThan1000MetersAwayGetsNewJSONData() {
        let mockViewController = MockNearbyPointsViewController()
        let mockNearbyPointsManager = MockNearbyPointsManager()
        mockNearbyPointsManager.currentLocation = TestPoints.Point1.location
        mockViewController.nearbyPointsManager = mockNearbyPointsManager
        mockViewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point3.location])
        let newMockNearbyPointsManager = mockViewController.nearbyPointsManager as! MockNearbyPointsManager
        XCTAssertEqual(newMockNearbyPointsManager.askedToGetGeonamesJSONData, true, "ViewController without a nearbyPointsManager should create one and call getGeonamesJSONData")
    }
    
}

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
        viewController.nearbyPointsManager = manager
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewControllerHasANearbyPointsManager() {
        XCTAssertNotNil(viewController.nearbyPointsManager!, "Nearby Points View Controller should have a Nearby Points manager")
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
    
    func testSettingManagerToNilStopsAppendingOfOldNearbyPointsWithAltitude() {
        let point1 = TestPoints.Point1
        point1.managerDelegate = manager
        manager.managerDelegate = viewController
        viewController.locationManager(locationManager, didUpdateLocations: [point1.location])
        manager.successfullyRetrievedAltitude(point1)
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [point1], "viewController should have received the NearbyPoint and appended it to nearbyPointsWithAltitude")

        let point3 = TestPoints.Point3
        point3.managerDelegate = manager
        manager = nil
        viewController.locationManager(locationManager, didUpdateLocations: [point3.location])
        point3.managerDelegate?.successfullyRetrievedAltitude(point3)
        XCTAssertEqual(viewController.currentLocation!, point3.location, "viewController should update its currentLocation")
        XCTAssertEqual(viewController.nearbyPointsWithAltitude!, [NearbyPoint](), "viewController should have received the NearbyPoint and appended it to nearbyPointsWithAltitude")
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
    
    func testHeadingWithNegativeHeadingAccuracyDoesNotSetCurrentHeading() {
        var heading = MockHeading(heading: 45.0)
        viewController.locationManager(locationManager, didUpdateHeading: heading)
        var negativeHeading = MockHeading(heading: 50.0, accuracy: -1)
        viewController.locationManager(locationManager, didUpdateHeading: negativeHeading)
        XCTAssertEqual(viewController.currentHeading!, heading.trueHeading, "ViewController should not update currentHeading when accuracy is negative")
    }
    
    func testViewControllerGetsPointsWithinFieldOfVisionOfCamera() {
        viewController.DeviceConstants = Constants(hfov: 58, vfoc: 32, phoneWidth: 650, phoneHeight: 376)
        viewController.nearbyPointsToShow = [Int]()
        viewController.nearbyPointsWithAltitude = [TestPoints.Holts, TestPoints.Smarts, TestPoints.Winslow]
        viewController.currentLocation = TestPoints.Holts.location
        viewController.currentHeading = 30.0
        viewController.getIndicesOfPointsWithinFieldOfVisionOfCamera()
        XCTAssertEqual(viewController.nearbyPointsToShow!, [1,2], "nearbyPointsToShow should contain the first two indices of nearbyPointsWithAltitude because iPhone is pointed in their direction")
        
    }
    
    func testUpdatingCurrentHeadingSetsNearbyPointsToShow() {
        viewController.DeviceConstants = Constants(hfov: 58, vfoc: 32, phoneWidth: 650, phoneHeight: 376)
        viewController.nearbyPointsToShow = [Int]()
        viewController.nearbyPointsWithAltitude = [TestPoints.Holts, TestPoints.Smarts, TestPoints.Winslow]
        viewController.currentLocation = TestPoints.Holts.location
        viewController.locationManager(locationManager, didUpdateHeading: MockHeading(heading:60))
        XCTAssertEqual(viewController.nearbyPointsToShow!, [1,2], "nearbyPointsToShow should contain the first two indices of nearbyPointsWithAltitude because iPhone is pointed in their direction")
    }
    
    func testViewDidLoadCreatesEmptyNearbyPointsSubviews() {
        viewController.viewDidLoad()
        XCTAssertTrue(viewController.nearbyPointsSubviews != nil, "nearbyPointsSubviews should be initialized and empty")
    }
    

}

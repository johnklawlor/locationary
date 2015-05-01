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
import CoreMotion

class NearbyPointsViewControllerTests: XCTestCase {

    var viewController = NearbyPointsViewController()
    var manager: NearbyPointsManager!
    var mockViewController = MockNearbyPointsViewController()
    var mockManager: MockNearbyPointsManager!
    var locationManager = CLLocationManager()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController.locationManager = locationManager
        viewController.motionManager = CMMotionManager()
        manager = NearbyPointsManager(delegate: viewController)
        viewController.nearbyPointsManager = manager
        viewController.locationManager(locationManager, didUpdateLocations: [Location.One])
        
        mockViewController.locationManager = locationManager
        mockManager = MockNearbyPointsManager(delegate: mockViewController)
        mockViewController.nearbyPointsManager = mockManager
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewControllerInitialesNearbyPointsWithAltitudeWhenCurrentLocationIsNil() {
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [NearbyPoint](), "When locationManager updates location and nearbyPointsManager's currentLocation is nil, viewController initializes an empty nearbyPointsWithAltitude array")
    }
    
    func testViewControllerNearbyPointsManagersCurrentLocationWhenCurrentLocationIsNil() {
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsManager.currentLocation!, TestPoints.Point1.location, "When locationManager updates location and nearbyPointsManager's currentLocation is nil, viewController sets nearbyPointsManager's currentLocation")
    }

    func testViewControllerDoesNotRenitialesNearbyPointsWithAltitudeArrayWhenCurrentLocationIsSet() {
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        viewController.nearbyPointsInLineOfSight = [TestPoints.Point1]
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [TestPoints.Point1], "Resetting viewController's currentLocation is less than 1000 away from new value of currentLocation does not initialize an empty nearbyPointsWithAltitude array")
    }
    
    func testViewControllerReinitializesNearbyPointsWithAltitudeArrayWhenCurrentIsSetAndDistanceToNewCurrentLocationValueIsGreaterThan1000(){
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point1.location])
        viewController.nearbyPointsInLineOfSight = [TestPoints.Point1]
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point3.location])
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [NearbyPoint](), "Resetting viewController's currentLocation is less than 1000 away from new value of currentLocation does not initialize an empty nearbyPointsWithAltitude array")
    }
    
    func testSettingNewNearbyPointsManagerStopsAppendingOfOldNearbyPointsWithAltitude() {
        viewController.nearbyPointsManager = manager
        let point1 = TestPoints.Point1
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Holts.location])
        point1.altitudeManagerDelegate = viewController.nearbyPointsManager
        point1.altitudeManagerDelegate!.successfullyRetrievedAltitude(point1)
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [point1], "viewController should have received the NearbyPoint and appended it to nearbyPointsWithAltitude")

        let point2 = TestPoints.Point2
        point2.altitudeManagerDelegate = point1.altitudeManagerDelegate
        let point3 = TestPoints.Point3
        viewController.locationManager(locationManager, didUpdateLocations: [point3.location])
        println("point2 manager delegate: \(point2.altitudeManagerDelegate)")
        point2.altitudeManagerDelegate?.successfullyRetrievedAltitude(point2)
        XCTAssertEqual(viewController.nearbyPointsManager.currentLocation!, point3.location, "viewController should update its currentLocation")
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [NearbyPoint](), "viewController should NOT have received the NearbyPoint and appended it to nearbyPointsWithAltitude")
    }
    
    func testUpdatingHeadingConvertsCurrentHeadingToAngleWhichIsZeroAtThePositiveXAxisAndIncrementsCounterClockwise() {
        var heading = MockHeading(heading: 45.0)
        var newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading!, heading.trueHeading, "Both headings should match")
        heading = MockHeading(heading: 0.1)
        newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading!, CLLocationDirection(89.9), "Both headings should match")
        heading = MockHeading(heading: 180.0)
        newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading!, CLLocationDirection(270.0), "Both headings should match")
        heading = MockHeading(heading: 255.0)
        newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(heading.trueHeading)
        XCTAssertEqual(newHeading!, CLLocationDirection(195.0), "Both headings should match")
    }
    
    func testViewControllerGetsPointsWithinFieldOfVisionOfCamera() {
//        viewController.DeviceConstants = Constants(hfov: 58, vfoc: 32, phoneWidth: 650, phoneHeight: 376)
//        viewController.nearbyPointsToShow = [Int]()
//        viewController.nearbyPointsWithAltitude = [TestPoints.Holts, TestPoints.Smarts, TestPoints.Winslow]
//        viewController.currentHeading = 30.0
//        viewController.getIndicesOfPointsWithinFieldOfVisionOfCamera()
//        XCTAssertEqual(viewController.nearbyPointsToShow!, [1,2], "nearbyPointsToShow should contain the first two indices of nearbyPointsWithAltitude because iPhone is pointed in their direction")
        
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
    
    func testUpdatingLocationForFirstTimeGetsGeonamesJSONData() {
        let mockViewController = MockNearbyPointsViewController()
        mockViewController.nearbyPointsManager = MockNearbyPointsManager(delegate: mockViewController)
        mockViewController.locationManager(locationManager, didUpdateLocations: [Location.One])
        let mockNearbyPointsManager = mockViewController.nearbyPointsManager as! MockNearbyPointsManager
        XCTAssertEqual(mockNearbyPointsManager.askedToGetGeonamesJSONData, true, "ViewController without a nearbyPointsManager should create one and call getGeonamesJSONData")
    }
    
    func testUpdatingLocationGreaterThan1000MetersAwayGetsNewJSONData() {
        manager.currentLocation = TestPoints.Point1.location
        mockViewController.nearbyPointsManager = manager
        mockViewController.locationManager(locationManager, didUpdateLocations: [TestPoints.Point3.location])
        XCTAssertTrue(mockViewController.createdNewNearbyPointsManager == true, "ViewController should create a new instance of NearbyPointsManager to get new Geonames data")
    }
    
    func testUpdatingLocationToLessThan1000MetersFromOldLocationRecalculatesAngleAndDistanceInNearbyPointsWithAltitude() {
        mockManager.currentLocation = TestPoints.Holts.location
        viewController.nearbyPointsManager = mockManager
        viewController.locationManager(locationManager, didUpdateLocations: [TestPoints.NearHolts.location])
        XCTAssertEqual(mockManager.currentLocation!, TestPoints.NearHolts.location, "ViewController with a nearbyPointsManager should update nearbyPointsManager's currentLocation when updated location is less than 1000 meters")
        XCTAssertEqual(mockManager.updatedDistances, true, "ViewController should have called its nearbyPointsManager to update distances and angles for the new location")
    }

    
    func testPassingNilToGetAngleInNewCoordinateSystemReturnsNil() {
        let newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(nil)
        XCTAssertNil(newHeading, "ReturnHeadingBasedInProperCoordinateSystem should return nil when passed nil")
    }
    
    func testTapOnNearbyPointLabelShowsATextLabelWithTheNameOfTheNearbyPoint() {
        var nearbyPoint = TestPoints.Smarts
        nearbyPoint.label = UIButton(frame: CGRectMake(200, 200, 17, 16))
        
        let testLabel = UILabel()
        testLabel.text = TestPoints.Smarts.name
        testLabel.sizeToFit()
        let testWidth = testLabel.frame.width
        
        viewController.view.addSubview(nearbyPoint.label)
        viewController.nearbyPointsInLineOfSight = [nearbyPoint]
        viewController.nameLabel = UILabel()
        viewController.didReceiveTapForNearbyPoint(nearbyPoint)
        let nameLabel = viewController.nameLabel
        XCTAssertEqual(nameLabel.text!, "Smarts Mountain", "View Controller updates nameLabel's text up receiving tap delegation call")
        XCTAssertEqual(nameLabel.frame.width, testWidth, "nameLabel should have proper width")
        
        let newTestLabel = nearbyPoint.label.subviews.first as! UILabel
        XCTAssertEqual(newTestLabel, viewController.nameLabel, "nearbyPoint's label should have the text label added to its subviews")
        XCTAssertFalse(viewController.nameLabel.hidden, "The text label should not be hidden")
    }
    
    func testCreateNewNearbyPointsManagerCreatesNewNearbyPointManager() {
        viewController.nearbyPointsManager = manager
        viewController.createNewNearbyPointsManager()
        XCTAssertNotEqual(viewController.nearbyPointsManager, manager, "New nearbyPointsManager should have been created")
    }
    
    func testViewControllerIsLocationManagersDelegate() {
        viewController.locationManager = locationManager
        let delegate = locationManager.delegate as! NearbyPointsViewController
        XCTAssertEqual(viewController, delegate, "ViewController should be location manager's delegate")
    }
    
    func testViewControllerCallsNearbyPointManagerToDetermineIfPointsAreInLineOfSight() {
        viewController.nearbyPointsManager = mockManager
        viewController.assembledNearbyPointsWithoutAltitude()
        XCTAssertTrue(mockManager.askedToDetermineIfEachPointIsInLineOfSight == true, "Manager should have been asked to determine if nearbyPoints are in line of sight of current location")
    }
    
    func testViewControllersTellsManagerToGetAltitudeDataForAllNearbyPointsAfterAssemblingNearbyPointsWithoutAltitudeArray() {
        mockViewController.assembledNearbyPointsWithoutAltitude()
        XCTAssertTrue(mockManager.askedToGetAltitudeJSONDataForEachPoint, "ViewController should ask manager to getAltitudeJSONDataForEachPoint")
    }
    
    func testCallFromNearbyPointsManagerOfSuccessfulRetrievalOfAltitudeAndDistancesMakesCallToNearbyPointsManagerToDetermineIfPointIsInLineOfSight() {
        mockViewController.retrievedNearbyPointWithAltitudeAndUpdatedDistance(TestPoints.Holts)
        XCTAssertTrue(mockManager.askedToGetElevationProfileDataForPoint, "ViewController should ask its manager to get elevation profile data after retrieveing altitude and distance data")
    }
    
}

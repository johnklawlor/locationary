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
    
    var testPoints = TestPoints()
    
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
        mockViewController.motionManager = CMMotionManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewControllerInitialesNearbyPointsWithAltitudeWhenCurrentLocationIsNil() {
        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [NearbyPoint](), "When locationManager updates location and nearbyPointsManager's currentLocation is nil, viewController initializes an empty nearbyPointsWithAltitude array")
    }
    
    func testViewControllerNearbyPointsManagersCurrentLocationWhenCurrentLocationIsNil() {
        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsManager.currentLocation!, testPoints.Point1.location, "When locationManager updates location and nearbyPointsManager's currentLocation is nil, viewController sets nearbyPointsManager's currentLocation")
    }

    func testViewControllerDoesNotReinitializeNearbyPointsInLineOfSightArrayWhenCurrentLocationIsSet() {
        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point1.location])
        viewController.nearbyPointsInLineOfSight = [testPoints.Point1]
        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point1.location])
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [testPoints.Point1], "Resetting viewController's when currentLocation is less than 1000 away from new value of currentLocation does not initialize an empty nearbyPointsInLineOfSight array")
    }
    
    func testViewControllerReinitializesNearbyPointsInLineOfSightArrayWhenCurrentIsSetAndDistanceToNewCurrentLocationValueIsGreaterThan1000(){
        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point1.location])
        viewController.nearbyPointsInLineOfSight = [testPoints.Point1]
        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point3.location])
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [NearbyPoint](), "Resetting viewController's when currentLocation is greater than 1000 away from new value of currentLocation reinitializes an empty nearbyPointsInLineOfSight array")
    }
    
    func testSettingNewNearbyPointsManagerStopsAppendingOfOldNearbyPoints() {
//        viewController.nearbyPointsManager = manager
//        let point1 = testPoints.Point1
//        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.Holts.location])
//        point1.elevationManagerDelegate = viewController.nearbyPointsManager
//        point1.elevationManagerDelegate!.successfullyRetrievedAltitude(point1)
//        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [point1], "viewController should have received the NearbyPoint and appended it to nearbyPointsWithAltitude")
//
//        let point2 = testPoints.Point2
//        point2.altitudeManagerDelegate = point1.altitudeManagerDelegate
//        let point3 = testPoints.Point3
//        viewController.locationManager(locationManager, didUpdateLocations: [point3.location])
//        println("point2 manager delegate: \(point2.altitudeManagerDelegate)")
//        point2.altitudeManagerDelegate?.successfullyRetrievedAltitude(point2)
//        XCTAssertEqual(viewController.nearbyPointsManager.currentLocation!, point3.location, "viewController should update its currentLocation")
//        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [NearbyPoint](), "viewController should NOT have received the NearbyPoint and appended it to nearbyPointsWithAltitude")
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
//        viewController.nearbyPointsWithAltitude = [testPoints.Holts, testPoints.Smarts, testPoints.Winslow]
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
        manager.currentLocation = testPoints.Point1.location
        mockViewController.nearbyPointsManager = manager
        mockViewController.locationManager(locationManager, didUpdateLocations: [testPoints.Point3.location])
        XCTAssertTrue(mockViewController.createdNewNearbyPointsManager == true, "ViewController should create a new instance of NearbyPointsManager to get new Geonames data")
    }
    
//    func testUpdatingLocationToLessThan1000MetersFromOldLocationRecalculatesAngleAndDistanceInNearbyPointsWithAltitude() {
//        mockManager.currentLocation = testPoints.Holts.location
//        viewController.nearbyPointsManager = mockManager
//        viewController.locationManager(locationManager, didUpdateLocations: [testPoints.NearHolts.location])
//        
//        let delegate = mockManager.elevationDataManager?.dataDelegate as? MockNearbyPointsManager
//        let currentLocationDelegate = mockManager.elevationDataManager?.currentLocationDelegate as? MockNearbyPointsManager
//        
//        XCTAssertEqual(mockManager, currentLocationDelegate!, "NearbyPointsManager should be ElevationDataManager's currentLocationDelegate")        
//        XCTAssertNotNil(mockManager.elevationDataManager, "NearbyPointsManager should have an ElevationDataManager")
//        XCTAssertEqual(mockManager, delegate!, "NearbyPointsManager should be ElevationDataManager's dataDelegate")
//        XCTAssertEqual(mockManager.currentLocation!, testPoints.NearHolts.location, "ViewController with a nearbyPointsManager should update nearbyPointsManager's currentLocation when updated location is less than 1000 meters")
//        XCTAssertEqual(mockManager.askedToDetermineIfEachPointIsInLineOfSight, true, "ViewController should have called its nearbyPointsManager to update distances and angles for the new location")
//    }

    
    func testPassingNilToGetAngleInNewCoordinateSystemReturnsNil() {
        let newHeading = viewController.returnHeadingBasedInProperCoordinateSystem(nil)
        XCTAssertNil(newHeading, "ReturnHeadingBasedInProperCoordinateSystem should return nil when passed nil")
    }
    
    func testTapOnNearbyPointLabelShowsATextLabelWithTheNameOfTheNearbyPoint() {
        var nearbyPoint = testPoints.Smarts
        nearbyPoint.label = UIButton(frame: CGRectMake(200, 200, 17, 16))
        
        let testLabel = UILabel()
        testLabel.text = testPoints.Smarts.name
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
        let newManager = viewController.nearbyPointsManager
        XCTAssertNotEqual(newManager, manager, "New nearbyPointsManager should have been created")
        XCTAssertNotNil(newManager.communicator, "New NearbyPointsManager should have a GeonamesCommunicator")
        let delegate = newManager.communicator!.geonamesCommunicatorDelegate as! NearbyPointsManager
        XCTAssertTrue(delegate === newManager, "New NearbyPointsManager should be GeonamesCommunicator's delegate")
        XCTAssertNotNil(newManager.parser, "New NearbyPointsManager should have a parser")
    }
    
    func testViewControllerIsLocationManagersDelegate() {
        viewController.locationManager = locationManager
        let delegate = locationManager.delegate as! NearbyPointsViewController
        XCTAssertEqual(viewController, delegate, "ViewController should be location manager's delegate")
    }
    
    func testViewControllerCallsNearbyPointManagerToDetermineIfPointsAreInLineOfSight() {
        viewController.nearbyPointsManager = mockManager
        viewController.assembledNearbyPointsWithoutAltitude()
        
        let delegate = mockManager.elevationDataManager?.dataDelegate as? MockNearbyPointsManager
        let currentLocationDelegate = mockManager.elevationDataManager?.currentLocationDelegate as? MockNearbyPointsManager
        
        XCTAssertEqual(mockManager, currentLocationDelegate!, "NearbyPointsManager should be ElevationDataManager's currentLocationDelegate")
        XCTAssertNotNil(mockManager.elevationDataManager, "NearbyPointsManager should have an ElevationDataManager")
        XCTAssertEqual(mockManager, delegate!, "NearbyPointsManager should be ElevationDataManager's dataDelegate")
        XCTAssertTrue(mockManager.askedToDetermineIfEachPointIsInLineOfSight == true, "Manager should have been asked to determine if nearbyPoints are in line of sight of current location")
    }
    
    func testCallFromNearbyPointsManagerOfSuccessfulFindOfNearbyPointInLineOfSightAppendsSaidPointToNearbyPointsInLineOfSightArray() {
        viewController.nearbyPointsInLineOfSight = [NearbyPoint]()
        testPoints.Holts.label = UIButton()
        viewController.foundNearbyPointInLineOfSight(testPoints.Holts)
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [testPoints.Holts], "ViewController should append successfully retrieved NearbyPoint in line of sight of current location")
        testPoints.Smarts.label = UIButton()
        viewController.foundNearbyPointInLineOfSight(testPoints.Smarts)
        XCTAssertEqual(viewController.nearbyPointsInLineOfSight!, [testPoints.Holts, testPoints.Smarts], "ViewController should append successfully retrieved NearbyPoint in line of sight of current location")
    }
    
    func testResponseToTapOnNearbyPointLabelButton() {
        testPoints.Holts.label = UIButton()
        testPoints.Holts.label.frame = CGRect(x: 50, y: 50, width: 40, height: 40)
        
        viewController.didReceiveTapForNearbyPoint(testPoints.Holts)
        
        let nameLabel = viewController.nameLabel
        
        let testLabel = UILabel()
        testLabel.text = "Holts Ledge"
        testLabel.sizeToFit()
        let testWidth = testLabel.frame.width
        let testHeight = testLabel.frame.height
        let x = (testPoints.Holts.label.frame.width - testWidth)/2
        let frameNameLabelShouldBe = CGRect(x: x, y: -testHeight, width: testWidth, height: testHeight)
        
        XCTAssertTrue(nameLabel.text == "Holts Ledge", "ViewController's nameLabel's text should be the name of the NearbyPoint that was tapped")
        XCTAssertEqual(nameLabel.frame, frameNameLabelShouldBe, "nameLabel's frame should be center and aligned along the bottom")
        XCTAssertFalse(nameLabel.hidden, "The nameLabel should NOT be hidden")
    }
    
    func testTappingOnPlaceOnScreenWhereThereIsNoPointHidesNameLabel() {
        testPoints.Holts.label = UIButton()
        testPoints.Holts.label.frame = CGRect(x: 50, y: 50, width: 40, height: 40)
        
        let tap = UITapGestureRecognizer()
        viewController.didReceiveTapOnView(tap)
        
        let nameLabel = viewController.nameLabel
        
        XCTAssertTrue(nameLabel.hidden, "The nameLabel should be hidden when a user taps on something other than a point")
    }
    
    func testThatADoubleTapExpandsNearbyPointsWithin50PixelSquare() {
        var holtsLabel = UIButton()
        holtsLabel.frame = CGRect(x: 49, y: 49, width: 40, height: 40)
        testPoints.Holts.label = holtsLabel
        var nearHoltsLabel = UIButton()
        nearHoltsLabel.frame = CGRect(x: 50, y: 50, width: 40, height: 40)
        testPoints.NearHolts.label = nearHoltsLabel
        var winslowLabel = UIButton()
        winslowLabel.frame = CGRect(x: 51, y: 51, width: 40, height: 40)
        testPoints.Winslow.label = winslowLabel
        
        viewController.nearbyPointsInLineOfSight = [testPoints.Holts, testPoints.NearHolts, testPoints.Winslow]
        
        viewController.view.addSubview(holtsLabel)
        viewController.view.addSubview(nearHoltsLabel)
        viewController.view.addSubview(winslowLabel)
        
        let point = CGPoint(x: 50, y: 50)
        var doubleTap = MockDoubleTap(point: point)
        viewController.didReceiveDoubleTapOnView(doubleTap)
        
        XCTAssertEqual(holtsLabel.frame.origin, CGPoint(x: 34, y: 49), "A double tap should expand the nearbyPoints")
    }
    
    func testThatALongPressResumeMotionManager() {
        
        mockViewController.didReceiveLongPressOnView(UILongPressGestureRecognizer())
        
        XCTAssertTrue(mockViewController.receivedLongPress, "The viewController's motionManager should be active")
    }
    
}

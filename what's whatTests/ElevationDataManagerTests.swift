//
//  ElevationDataManagerTests.swift
//  what's what
//
//  Created by John Lawlor on 6/2/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest

class ElevationDataManagerTests: XCTestCase {
    
    var elevationDataManager = ElevationDataManager()
    var mockViewController = MockNearbyPointsViewController()
    var mockManager: MockNearbyPointsManager!
    
    var testPoints = TestPoints()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mockManager = MockNearbyPointsManager(delegate: mockViewController)
        
        elevationDataManager.dataDelegate = mockManager
        elevationDataManager.currentLocationDelegate = mockManager
        
        elevationDataManager.gdalManager = GDALWrapper()
        println("elevationFilename: \(ManagerConstants.ElevationDataFilename)")
        elevationDataManager.gdalManager?.openGDALFile(ManagerConstants.ElevationDataFilename)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testElevationDataManagersHasCorrentCurrentLocation() {
        mockManager.currentLocation = testPoints.GoosePond.location
        let currentLocation = elevationDataManager.currentLocationDelegate?.currentLocation
        
        XCTAssertEqual(currentLocation!, testPoints.GoosePond.location, "ElevationDataManager should have NearbyPointsManager's currentLocation")
    }
    
    func testElevationDataManagerReturnsProperLineOfSightDataForGoosePondLookingAtWinslow() {
        
        mockManager.currentLocation = testPoints.GoosePond.location
        testPoints.Winslow.distanceFromCurrentLocation = testPoints.GoosePond.location.distanceFromLocation(testPoints.Winslow.location)
        
        elevationDataManager.getElevationForPoint(testPoints.Winslow)
        
        XCTAssertTrue(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Winslow should be in the line of sight of the Dismal")
        XCTAssertEqual(mockManager.nearbyPointToUpdate, testPoints.Winslow, "Manager should have been passed NearbyPoint Winslow")
    }
    
    func testElevationDataManagerReturnsProperLineOfSightDataForWinslowLookingAtGoosePond() {
        
        mockManager.currentLocation = testPoints.Winslow.location
        testPoints.GoosePond.distanceFromCurrentLocation = testPoints.Winslow.location.distanceFromLocation(testPoints.GoosePond.location)
        
        elevationDataManager.getElevationForPoint(testPoints.GoosePond)
        
        XCTAssertTrue(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Winslow should be in the line of sight of the Dismal")
        XCTAssertEqual(mockManager.nearbyPointToUpdate, testPoints.GoosePond, "Manager should have been passed NearbyPoint Winslow")
    }
    
    func testElevationDataManagerReturnsProperLineOfSightDataForGoosePondLookingAtKillington() {
        
        mockManager.currentLocation = testPoints.GoosePond.location
        testPoints.Killington.distanceFromCurrentLocation = testPoints.GoosePond.location.distanceFromLocation(testPoints.Killington.location)
        
        elevationDataManager.getElevationForPoint(testPoints.Killington)
        
        XCTAssertFalse(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Killington should not be in the line of sight of Goose Pond")
    }
    
    func testElevationDataManagerReturnsProperLineOfSightDataForCliffStLookingAtWashington() {
        
        let currentLocation = testPoints.CliffSt
        let nearbyPoint = testPoints.MountWashington
        mockManager.currentLocation = currentLocation.location
        nearbyPoint.distanceFromCurrentLocation = currentLocation.location.distanceFromLocation(nearbyPoint.location)
        
        elevationDataManager.getElevationForPoint(nearbyPoint)
        
        XCTAssertFalse(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Washington should not be in the line of sight of Cliff St.")
    }

}

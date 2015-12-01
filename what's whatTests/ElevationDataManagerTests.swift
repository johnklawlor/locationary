//
//  ElevationDataManagerTests.swift
//  Locationary
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 John Lawlor. All rights reserved.
//
//  This file is part of Locationary.
//
//  Locationary is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Locationary is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
        
        elevationDataManager.gdalManager = TheGDALWrapper()
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
    
    func testElevationDataManagerReturnsProperLineOfSightDataForMapleLookingAtSmarts() {
        
        let currentLocation = testPoints.MapleAndWilley
        let nearbyPoint = testPoints.Smarts
        mockManager.currentLocation = currentLocation.location
        nearbyPoint.distanceFromCurrentLocation = currentLocation.location.distanceFromLocation(nearbyPoint.location)
        
        elevationDataManager.getElevationForPoint(nearbyPoint)
        
        XCTAssertTrue(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Maple should see Smarts")
    }

    func testElevationDataManagerReturnsProperLineOfSightDataForMapleLookingAtSupport() {
        
        let currentLocation = testPoints.CliffSt
        let nearbyPoint = testPoints.MountSupport
        mockManager.currentLocation = currentLocation.location
        nearbyPoint.distanceFromCurrentLocation = currentLocation.location.distanceFromLocation(nearbyPoint.location)
        
        elevationDataManager.getElevationForPoint(nearbyPoint)
        
        XCTAssertTrue(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Maple should see Support")
    }
    
    func testElevationDataManagerReturnsProperLineOfSightDataForBalchLookingAtAscutney() {
        
        let currentLocation = testPoints.Balch
        let nearbyPoint = testPoints.Ascutney
        mockManager.currentLocation = currentLocation.location
        nearbyPoint.distanceFromCurrentLocation = currentLocation.location.distanceFromLocation(nearbyPoint.location)
        
        elevationDataManager.getElevationForPoint(nearbyPoint)
        
        XCTAssertTrue(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Balch should see Ascutney")
    }

    func testElevationDataManagerReturnsProperLineOfSightDataForGileLookingAtHigley() {
        
        let currentLocation = testPoints.Gile
        let nearbyPoint = testPoints.Higley
        mockManager.currentLocation = currentLocation.location
        nearbyPoint.distanceFromCurrentLocation = currentLocation.location.distanceFromLocation(nearbyPoint.location)
        
        elevationDataManager.getElevationForPoint(nearbyPoint)
        
        XCTAssertFalse(mockManager.elevationDataForPointToUpdate.inLineOfSight, "Gile should not see Higley")
    }
    
}

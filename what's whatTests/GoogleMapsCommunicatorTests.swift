//
//  GoogleMapsCommunicatorTests.swift
//  what's what
//
//  Created by John Lawlor on 4/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest

class GoogleMapsCommunicatorTests: XCTestCase {

    var googleMapsCommunicator: GoogleMapsCommunicator! = GoogleMapsCommunicator()
    var mockGoogleMapsCommunicator: MockGoogleMapsCommunicatorTwo! = MockGoogleMapsCommunicatorTwo()
    var testPoints = TestPoints()
    
    override func setUp() {
        super.setUp()
        googleMapsCommunicator.googleMapsCommunicatorDelegate = testPoints.MockHolts
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGoogleMapsCommunicatorIsItsOwnCommunicatorDelegate() {
        let communicatorDelegate = googleMapsCommunicator.communicatorDelegate! as! GoogleMapsCommunicator
        XCTAssertTrue(communicatorDelegate === googleMapsCommunicator, "GoogleMapsCommunicator should be its own delegate to Communicator callbacks")
    }
    
    func testGoogleMapsCommunicatorPassesErrorAlongToItsDelegate() {
        googleMapsCommunicator.fetchingFailedWithError(CommunicatorConstants.Error_NoURLToFetch)
        XCTAssertEqual(testPoints.MockHolts.failError!, CommunicatorConstants.Error_NoURLToFetch, "GoogleMapsCommunicator should pass error to its delegate")
    }
    
    func testGoogleMapsCommunicatorPassesJSONStringToItsDelegate() {
        googleMapsCommunicator.receivedJSON("Elevation data")
        XCTAssertEqual(testPoints.MockHolts.jsonString!, "Elevation data", "GoogleMapsCommunicator passes JSON string to its delegate")
    }

    func testGoogleMapsCommunicatorReturnsCorrectURL() {
        googleMapsCommunicator.currentLocation = testPoints.Holts.location
        googleMapsCommunicator.locationOfNearbyPoint = testPoints.Killington.location
        XCTAssertEqual(googleMapsCommunicator.fetchingUrl!, NSURL(string: "http://maps.googleapis.com/maps/api/elevation/json?path=43.772333,-72.107691%7C43.604598,-72.819852&samples=10")!, "GoogleMapsCommunicator should return correct URL")
    }

}

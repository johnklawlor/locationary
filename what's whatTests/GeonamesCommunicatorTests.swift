//
//  GeonamesManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import XCTest
import Locationary
import CoreLocation

struct TestError {
    static let ForCommunicator = NSError(domain: "Bad domain", code: 420, userInfo: nil)
}

class GeonamesCommunicatorTests: XCTestCase {
    
    var NNCommunicator: NNGeonamesCommunicator!
    var communicator: GeonamesCommunicator!
    var manager: MockNearbyPointsManager!
    var locationA = CLLocation(coordinate: CLLocationCoordinate2DMake(43.739442,-72.021706), altitude: 0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
    var locationB = CLLocation(coordinate: CLLocationCoordinate2DMake(43.739435,-72.021708), altitude: 0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
    var receivedData = "Received data".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    var testRequest: NSURLRequest!
    var testConnection: NSURLConnection!

    override func setUp() {
        super.setUp()

        NNCommunicator = NNGeonamesCommunicator()
        communicator = GeonamesCommunicator()
        manager = MockNearbyPointsManager(delegate: NearbyPointsViewController())
        
        NNCommunicator.geonamesCommunicatorDelegate = manager
        NNCommunicator.currentLocation = locationA
        communicator.geonamesCommunicatorDelegate = manager
        communicator.currentLocation = locationA

        testRequest = NSURLRequest(URL: NNCommunicator.fetchingUrl!)
        testConnection = NSURLConnection(request: testRequest, delegate: NNCommunicator)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGeonamesCommunicatorIsItsOwnCommunicatorDelegate() {
        let communicatorDelegate = communicator.communicatorDelegate! as! GeonamesCommunicator
        XCTAssertTrue(communicatorDelegate === communicator, "GeonamesCommunicator should be its own delegate to Communicator callbacks")
    }
    
    func testManagerReturnsCorrectURL() {
        XCTAssertEqual("\(NNCommunicator.fetchingUrl!)", "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=42.834792&north=44.644092&west=-73.265058&east=-70.778354&orderby=elevation&username=jkl234", "Communicator should return correct URL")
    }
    
    func testFetchingJSONDataCreatesRequestAndLaunchesConnection() {
        communicator.fetchJSONData()
        XCTAssertNotNil(communicator.fetchingRequest, "Communicator should have an altitude request")
        XCTAssertNotNil(communicator.fetchingConnection, "Communicator should have an altitude connection")
        communicator.cancelAndDiscardConnection()
    }
    
    func testGeonamesCommunicatorInformsItsDelegateOfAnError() {
        communicator.geonamesCommunicatorDelegate?.fetchingNearbyPointsFailedWithError(TestError.ForCommunicator)
        XCTAssertEqual(manager.fetchingError!, TestError.ForCommunicator, "GeonamesCommunicator should pass error to its delegate")
    }
    
    func testGeonamesCommunicatorPassesJSONDataToDelegate() {
        communicator.geonamesCommunicatorDelegate?.receivedNearbyPointsJSON("Received data")
        XCTAssertEqual(manager.nearbyPointsJSON!, "Received data", "GeonamesCommunicator should pass JSON string to its delegate")
    }
    
    func testConnectionDidFailAddsOneToRequestAttemptsOnConnectionRetry() {
        NNCommunicator.currentLocation = locationA
        XCTAssertEqual(NNCommunicator.requestAttempts, 2, "Communicator should increment requestAttempts to 2")
    }
    
    func testSettingNewLocationResetsAttemptsForNewConnection() {
        NNCommunicator.currentLocation = locationB
        XCTAssertEqual(NNCommunicator.requestAttempts, 1, "Communicator should reset attempts to 1 when resetting the currentLocation")
    }
    
    func testGeonamesCommunicatorInformsDelegateOfReachingRequestAttemptLimit() {
        NNCommunicator.currentLocation = locationA
        XCTAssertEqual(NNCommunicator.requestAttempts, 2, "Communicator should increment requestAttempts to 2")
    }
    
}
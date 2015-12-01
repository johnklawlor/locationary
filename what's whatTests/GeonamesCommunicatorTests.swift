//
//  GeonamesManager.swift
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
    
    func testManagerReturnsCorrectURLForInitialRequest() {
        XCTAssertEqual("\(NNCommunicator.fetchingUrl!)", "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=42.834792&north=44.644092&west=-73.265058&east=-70.778354&orderby=elevation&username=jkl234&maxRows=2000&startRow=0", "Communicator should return correct URL")
    }
    
    func testManagerReturnsCorrectURLForSecondRequest() {
        NNCommunicator.startRowCount = 1
        XCTAssertEqual("\(NNCommunicator.fetchingUrl!)", "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=42.834792&north=44.644092&west=-73.265058&east=-70.778354&orderby=elevation&username=jkl234&maxRows=2000&startRow=2000", "Communicator should return correct URL")
    }
    
    func testManagerReturnsCorrectURLForThirdRequest() {
        NNCommunicator.startRowCount = 2
        XCTAssertEqual("\(NNCommunicator.fetchingUrl!)", "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=42.834792&north=44.644092&west=-73.265058&east=-70.778354&orderby=elevation&username=jkl234&maxRows=2000&startRow=4000", "Communicator should return correct URL")
    }
    
    func testFetchingJSONDataCreatesRequestAndLaunchesConnection() {
        communicator.fetchJSONData()
        dispatch_async(dispatch_get_main_queue()) {
            XCTAssertNotNil(self.communicator.fetchingRequest, "Communicator should have an altitude request")
            XCTAssertNotNil(self.communicator.fetchingConnection, "Communicator should have an altitude connection")
            self.communicator.cancelAndDiscardConnection()
        }
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
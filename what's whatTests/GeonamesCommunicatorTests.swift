//
//  GeonamesManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import XCTest
import what_s_what
import CoreLocation

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
    
    func testManagerReturnsCorrectURL() {
        XCTAssertEqual("\(NNCommunicator.fetchingUrl!)", "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=42.834792&north=44.644092&west=-73.265058&east=-70.778354&orderby=elevation&username=jkl234", "Communicator should return correct URL")
    }
    
    func testLaunchingNewConnectionCancelsCurrentConnection() {
        let request = NSURLRequest(URL: NNCommunicator.fetchingUrl!)
        let oldConnection = NSURLConnection(request: request, delegate: NNCommunicator)
        communicator.fetchingConnection = oldConnection
        communicator.launchConnectionForRequest(request)
        XCTAssertNotEqual(communicator.fetchingConnection!, oldConnection!, "Launching new connection cancels old one")
        communicator.cancelAndDiscardConnection()
    }
    
    func testFetchingGeonamesJSONDataCreatesFetchingRequestAndConnection() {
        communicator.fetchGeonamesJSONData()
        XCTAssertNotNil(communicator.fetchingRequest!, "Fetching Geonames JSON Data should create a request")
        XCTAssertNotNil(communicator.fetchingConnection!, "Fetching Geonames JSON Data should create a connection")
        communicator.cancelAndDiscardConnection()
    }
    
    func testConnectionErrorInformsDelegateOfError() {
        let FourOhFourResponse = FakeURLResponse(code: 404)
        NNCommunicator.connection(testConnection, didReceiveResponse: FourOhFourResponse!)
        XCTAssertEqual(manager.fetchingError!.code, 404, "Response error should have been passed to the delegate")
    }

    func testConnection200ResponseDoesNotInformDelegateOfError() {
        let TwoHundredResponse = FakeURLResponse(code: 200)
        NNCommunicator.connection(testConnection, didReceiveResponse: TwoHundredResponse!)
        XCTAssertNil(manager.fetchingError, "The communicator delegate should not have a response error");
    }
    
    func testConnectionDidFailWithErrorNotifiesCommunicatorDelegate() {
        let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        NNCommunicator.connection(testConnection, didFailWithError: error)
        NNCommunicator.fetchingConnection = testConnection
        let connectionFailErrorCode = manager.fetchingError!.code
        XCTAssertEqual(connectionFailErrorCode, 420, "Connection Failed error should have been passed to the delegate")
    }

    func testConnectionDidFailAddsOneToRequestAttemptsOnConnectionRetry() {
        let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        NNCommunicator.currentLocation = locationA
        XCTAssertEqual(NNCommunicator.requestAttempts, 2, "Communicator should increment requestAttempts to 2")
    }
    
    func testConnectionDidFailResetsAttemptsForNewConnection() {
        let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        NNCommunicator.currentLocation = locationB
        XCTAssertEqual(NNCommunicator.requestAttempts, 1, "Communicator should reset attempts to 1 when resetting the currentLocation")
    }
    
    func testConnectionPassedDataToDelegate() {
        NNCommunicator.setTheReceivedData(receivedData!)
        NNCommunicator.connectionDidFinishLoading(testConnection)
        let jsonData = manager.nearbyPointsJSON!
        XCTAssertEqual(jsonData, "Received data", "Manager should receive JSON data as string")
    }
    
    func testConnectionDidReceiveDataAppendsData() {
        NNCommunicator.setTheReceivedData(receivedData!)
        let moreData = ", plus more data".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        NNCommunicator.connection(testConnection, didReceiveData: moreData!)
        let jsonData = NSString(data: NNCommunicator.receivedData!, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(jsonData!, "Received data, plus more data", "connectionDidReceiveData should append data")
    }
    
    func testNewConnectionDiscardsOldData() {
        NNCommunicator.setTheReceivedData(receivedData!)
        NNCommunicator.fetchGeonamesJSONData()
        let fakeResponse = FakeURLResponse(code: 200)
        NNCommunicator.connection(testConnection, didReceiveResponse: fakeResponse!)
        XCTAssertNotEqual(receivedData!, NNCommunicator.receivedData!, "Old data should be discarded")
    }
    
}

//
//  AltitudeCommunicatorTests.swift
//  what's what
//
//  Created by John Lawlor on 3/30/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class CommunicatorTests: XCTestCase {

    var mockCommunicator: MockCommunicator!
    var communicator: Communicator!
    
    var mockGeonamesCommunicator: MockGeonamesCommunicator!

    var receivedData = "Received data".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    var testRequest: NSURLRequest!
    var testConnection: NSURLConnection!
    
    var testPoints = TestPoints()
    
    override func setUp() {
        super.setUp()

        communicator = Communicator()
        mockCommunicator = MockCommunicator()
        
        mockGeonamesCommunicator = MockGeonamesCommunicator()
        
        testRequest = NSURLRequest(URL: NSURL(string: "http://api.geonames.org/srtm3JSON?lat=43.720343&lng=-72.145562&username=jkl234")!)
        testConnection = NSURLConnection(request: testRequest, delegate: mockCommunicator)
        
        communicator.communicatorDelegate = testPoints.MockHolts
        mockCommunicator.communicatorDelegate = testPoints.MockHolts
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchingJSONDataWithoutURLInformsDelegateOfError() {
        communicator.communicatorDelegate = mockGeonamesCommunicator
        communicator.fetchJSONData()
        XCTAssertEqual(mockGeonamesCommunicator.fetchingError, CommunicatorConstants.Error_NoURLToFetch, "Communicator should passes no url error to its delegate if fetchingURL is nil")
    }
    
    func testLaunchingNewConnectionCancelsCurrentConnection() {
        let request = NSURLRequest(URL: NSURL(string: "www.google.com")!)
        let oldConnection = NSURLConnection(request: request, delegate: mockCommunicator)
        communicator.fetchingConnection = oldConnection
        communicator.launchConnectionForRequest(request)
        XCTAssertNotEqual(communicator.fetchingConnection!, oldConnection!, "Launching new connection cancels old one")
        communicator.cancelAndDiscardConnection()
    }

    func testCommunicatorNotifiesCommunicatorDelegateOfError() {
        let FourOhFourResponse = FakeURLResponse(code: 404)
        communicator.communicatorDelegate = testPoints.MockHolts
        communicator.connection(testConnection, didReceiveResponse: FourOhFourResponse!)
        XCTAssertEqual(testPoints.MockHolts.fetchingError!.code, 404, "Response error should have been passed to the delegate")
    }

    func testConnectionDidFailWithErrorNotifiesCommunicatorDelegate() {
        let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        communicator.fetchingConnection = testConnection
        communicator.connection(testConnection, didFailWithError: error)
        let connectionFailErrorCode = testPoints.MockHolts.fetchingError!.code
        XCTAssertEqual(connectionFailErrorCode, 420, "Connection Failed error should have been passed to the delegate")
    }

    func testConnectionDidReceiveResponseClearsOldData() {
        let TwoHundredResponse = FakeURLResponse(code: 200)

        mockCommunicator.setTheReceivedData(receivedData!)
        mockCommunicator.connection(testConnection, didReceiveResponse: TwoHundredResponse!)
        XCTAssertTrue(mockCommunicator.receivedData != receivedData!, "Receiving new response should clear old data")
    }
    
    func testConnectionDidReceiveDataAppenedsDataToReceiveDataVar() {
        mockCommunicator.receivedData = NSMutableData()
        mockCommunicator.connection(testConnection, didReceiveData: receivedData!)
        XCTAssertEqual(mockCommunicator.receivedData!, receivedData!, "Communicator should append received data")
    }
    
    func testConnectionDidFinishedLoadingPassesDataToDelegate() {
        mockCommunicator.setTheReceivedData(receivedData!)
        mockCommunicator.connectionDidFinishLoading(testConnection)
        XCTAssertEqual(testPoints.MockHolts.receivedJSON!, "Received data", "Communicator's delegate should have been passed JSON string")
    }
    
}

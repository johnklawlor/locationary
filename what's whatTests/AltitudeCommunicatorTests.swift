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

class AltitudeCommunicatorTests: XCTestCase {

    var mockCommunicator: MockAltitudeCommunicator!
    var communicator: AltitudeCommunicator!
    var locationA = CLLocation(coordinate: CLLocationCoordinate2DMake(43.739442,-72.021706), altitude: 0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
    var locationB = CLLocation(coordinate: CLLocationCoordinate2DMake(43.739435,-72.021708), altitude: 0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
    var receivedData = "Received data".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    var testRequest: NSURLRequest!
    var testConnection: NSURLConnection!
    var point1, point2: NearbyPoint!
    
    override func setUp() {
        super.setUp()
        // http://api.geonames.org/searchJSON?q=&featureCode=MT&south=43.614442&north=43.864442&west=-72.146706&east=-71.896706&maxRows=1&orderby=elevation&username=jkl234&elevation=true
        // http://api.geonames.org/srtm3JSON?lat=43.720343&lng=-72.145562&username=jkl234
        mockCommunicator = MockAltitudeCommunicator()
        communicator = AltitudeCommunicator()
        
        testRequest = NSURLRequest(URL: NSURL(string: "http://api.geonames.org/srtm3JSON?lat=43.720343&lng=-72.145562&username=jkl234")!)
        testConnection = NSURLConnection(request: testRequest, delegate: mockCommunicator)
        
        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name = "Smarts Mountain"
        point1 = NearbyPoint(aName: name, aLocation: location)
        let location2 = CLLocation(coordinate: CLLocationCoordinate2DMake(43.12563, -72.43231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        let name2 = "Smarts Mountain"
        point2 = NearbyPoint(aName: name, aLocation: location2)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testReturnsCorrectURL() {
        communicator.locationOfAltitudeToFetch = point1.location
        XCTAssertEqual(communicator.fetchingUrl!, NSURL(string: "http://api.geonames.org/srtm3JSON?lat=43.82563&lng=-72.03231&username=jkl234")!, "Communicator should return correct URL")
    }

    func testCommunicatorCreatesAltitudeRequestAndConnection() {
        communicator.locationOfAltitudeToFetch = point1.location
        communicator.fetchAltitudeJSONData()
        XCTAssertNotNil(communicator.fetchingAltitudeRequest, "Communicator should have an altitude request")
        XCTAssertNotNil(communicator.fetchingAltitudeConnection, "Communicator should have an altitude connection")
        communicator.cancelAndDiscardConnection()
    }

    func testCommunicatorNotifiesAltitudeDelegateOfError() {
        let FourOhFourResponse = FakeURLResponse(code: 404)
        communicator.altitudeCommunicatorDelegate = point1
        communicator.connection(testConnection, didReceiveResponse: FourOhFourResponse!)
        XCTAssertEqual(point1.fetchingError!.code, 404, "Response error should have been passed to the delegate")
    }

    func testConnectionDidFailWithErrorNotifiesCommunicatorDelegate() {
        communicator.altitudeCommunicatorDelegate = point1
        let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        communicator.fetchingAltitudeConnection = testConnection
        communicator.connection(testConnection, didFailWithError: error)
        let connectionFailErrorCode = point1.fetchingError!.code
        XCTAssertEqual(connectionFailErrorCode, 420, "Connection Failed error should have been passed to the delegate")
    }

    func testConnectionDidReceiveResponseClearsOldData() {
        let TwoHundredResponse = FakeURLResponse(code: 200)
        mockCommunicator.altitudeCommunicatorDelegate = point1
        mockCommunicator.setTheReceivedData(receivedData!)
        mockCommunicator.connection(testConnection, didReceiveResponse: TwoHundredResponse!)
        XCTAssertTrue(mockCommunicator.receivedData != receivedData!, "Receiving new response should clear old data")
    }
    
    func testConnectionDidReceiveDataAppenedsDataToReceiveDataVar() {
        mockCommunicator.altitudeCommunicatorDelegate = point1
        mockCommunicator.receivedData = NSMutableData()
        mockCommunicator.connection(testConnection, didReceiveData: receivedData!)
        XCTAssertEqual(mockCommunicator.receivedData!, receivedData!, "Communicator should append received data")
    }
    
    func testConnectionDidFinishedLoadingInformsDelegate() {
        mockCommunicator.altitudeCommunicatorDelegate = point1
        mockCommunicator.setTheReceivedData(receivedData!)
        mockCommunicator.connectionDidFinishLoading(testConnection)
        XCTAssertEqual(point1.altitudeJSONString!, "Received data", "Communicator's delegate should have been passed JSON string")
    }
}

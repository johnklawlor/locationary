//
//  AltitudeCommunicatorTests.swift
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
        
        communicator.communicatorDelegate = mockGeonamesCommunicator
        mockCommunicator.communicatorDelegate = mockGeonamesCommunicator
        
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
        communicator.connection(testConnection, didReceiveResponse: FourOhFourResponse!)
        XCTAssertEqual(mockGeonamesCommunicator.fetchingError!.code, 404, "Response error should have been passed to the delegate")
    }

    func testConnectionDidFailWithErrorNotifiesCommunicatorDelegate() {
        let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        communicator.fetchingConnection = testConnection
        communicator.connection(testConnection, didFailWithError: error)
        let connectionFailErrorCode = mockGeonamesCommunicator.fetchingError!.code
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
        XCTAssertEqual(mockGeonamesCommunicator.receivedJSON, "Received data", "Communicator's delegate should have been passed JSON string")
    }
    
}

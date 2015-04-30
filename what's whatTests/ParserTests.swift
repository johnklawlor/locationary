//
//  ParserTests.swift
//  what's what
//
//  Created by John Lawlor on 3/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation

class ParserTests: XCTestCase {
    
    var parser = GeonamesJSONParser()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParserReturnsNilIfPassedAnEmptyString() {
        let (nearbyPoints, error) = parser.buildAndReturnArrayFromJSON("")
        XCTAssertTrue(nearbyPoints == nil, "Parser buildAndReturnArrayFromJSON should return nil if passed an empty string")
    }

    func testParserReturnsErrorIfPassedAnEmptyString() {
        let (nearbyPoints, error) = parser.buildAndReturnArrayFromJSON("")
        XCTAssertNotNil(error, "Parser buildAndReturnArrayFromJSON should return error if passed an empty string")
    }
    
    func testParserReturnsErrorIfPassedNotJSONString() {
//      let error = NSError(domain: "Bad domain", code: 420, userInfo: nil)
        let (nearbyPoints, error) = parser.buildAndReturnArrayFromJSON(Strings.NotJson)
        XCTAssertNotNil(error, "Parser should return error if not passed proper JSON")
    }

    func testParserReturnsDictionaryWithTwoObjects() {
        let (nearbyPoints, error) = parser.buildAndReturnArrayFromJSON(Strings.jsonFromCommunicator)
        XCTAssertNil(error, "Parser should not return an error if passed proper JSON")
        XCTAssertTrue(nearbyPoints != nil, "Parser should return two CLLocation objects in an array")
        XCTAssertEqual(nearbyPoints!.count, 2, "Parser should return two CLLocation objects in an array")
    }
    
    func testParserReturnsCorrectInformation() {
        let (nearbyPointObjects, error) = parser.buildAndReturnArrayFromJSON(Strings.jsonFromCommunicator)
        let nearbyPoints = nearbyPointObjects as? [NearbyPoint]
        let firstReturned = nearbyPoints!.first!
        let firstLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(43.82563, -72.03231), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        XCTAssertEqual(firstReturned.location.coordinate.latitude, firstLocation.coordinate.latitude, "Returned location should be the same as the given location")
        XCTAssertEqual(firstReturned.location.coordinate.longitude, firstLocation.coordinate.longitude, "Returned location should be the same as the given location")
        XCTAssertEqual(firstReturned.location.altitude, firstLocation.altitude, "Returned location should be the same as the given location")
        XCTAssertEqual(firstReturned.name, "Smarts Mountain", "Name should be the same")
        
        let secondReturned = nearbyPoints![1]
        let secondLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(43.64979, -71.9148), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        XCTAssertEqual(secondReturned.location.coordinate.latitude, secondLocation.coordinate.latitude, "Returned location should be the same as the given location")
        XCTAssertEqual(secondReturned.location.coordinate.longitude, secondLocation.coordinate.longitude, "Returned location should be the same as the given location")
        XCTAssertEqual(secondReturned.location.altitude, secondLocation.altitude, "Returned location should be the same as the given location")
        XCTAssertEqual(secondReturned.name, "Mount Cardigan", "Name should be the same")
    }
    
    func testBadLatitudeDoesNotAddPointToArray() {
        let (nearbyPoints, error) = parser.buildAndReturnArrayFromJSON(Strings.badLatitude)
        XCTAssertEqual(nearbyPoints!.count, 1, "Parser should add only location with good lats and longs")
    }
    
    func testParsingAltitudeCommunicatorReturnsCorrectValue() {
        let (altitude, error) = parser.buildAndReturnArrayFromJSON(Strings.jsonFromAltitudeCommunicator)
        let altitudeValue = altitude as? [NSInteger]
        XCTAssertTrue(altitudeValue?.first! == 694, "Parser should return correct integer value")
    }
}

extension XCTest {
    struct Strings {
        static let jsonFromCommunicator = "{\"totalResultsCount\":25,\"geonames\":[{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-72.03231\",\"fcodeName\":\"mountain\",\"toponymName\":\"Smarts Mountain\",\"fcl\":\"T\",\"name\":\"Smarts Mountain\",\"fcode\":\"MT\",\"geonameId\":5092739,\"lat\":\"43.82563\",\"adminName1\":\"New Hampshire\",\"population\":0},{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-71.9148\",\"fcodeName\":\"mountain\",\"toponymName\":\"Mount Cardigan\",\"fcl\":\"T\",\"name\":\"Mount Cardigan\",\"fcode\":\"MT\",\"geonameId\":5084213,\"lat\":\"43.64979\",\"adminName1\":\"New Hampshire\",\"population\":0}]}"
        static let badLatitude = "{\"totalResultsCount\":25,\"geonames\":[{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-72.03231\",\"fcodeName\":\"mountain\",\"toponymName\":\"Smarts Mountain\",\"fcl\":\"T\",\"name\":\"Smarts Mountain\",\"fcode\":\"MT\",\"geonameId\":5092739,\"lat\":\"\",\"adminName1\":\"New Hampshire\",\"population\":0},{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-71.9148\",\"fcodeName\":\"mountain\",\"toponymName\":\"Mount Cardigan\",\"fcl\":\"T\",\"name\":\"Mount Cardigan\",\"fcode\":\"MT\",\"geonameId\":5084213,\"lat\":\"43.64979\",\"adminName1\":\"New Hampshire\",\"population\":0}]}"
        static let NotJson = "Not JSON"
        
        static let jsonFromAltitudeCommunicator = "{\"srtm3\":694,\"lng\":-72.145562,\"lat\":43.720343}"
    }
}

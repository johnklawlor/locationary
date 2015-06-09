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

struct Strings {
    static let jsonFromCommunicator = "{\"totalResultsCount\":25,\"geonames\":[{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-72.03231\",\"fcodeName\":\"mountain\",\"toponymName\":\"Smarts Mountain\",\"fcl\":\"T\",\"name\":\"Smarts Mountain\",\"fcode\":\"MT\",\"geonameId\":5092739,\"lat\":\"43.82563\",\"adminName1\":\"New Hampshire\",\"population\":0},{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-71.9148\",\"fcodeName\":\"mountain\",\"toponymName\":\"Mount Cardigan\",\"fcl\":\"T\",\"name\":\"Mount Cardigan\",\"fcode\":\"MT\",\"geonameId\":5084213,\"lat\":\"43.64979\",\"adminName1\":\"New Hampshire\",\"population\":0}]}"
    static let badLatitude = "{\"totalResultsCount\":25,\"geonames\":[{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-72.03231\",\"fcodeName\":\"mountain\",\"toponymName\":\"Smarts Mountain\",\"fcl\":\"T\",\"name\":\"Smarts Mountain\",\"fcode\":\"MT\",\"geonameId\":5092739,\"lat\":\"\",\"adminName1\":\"New Hampshire\",\"population\":0},{\"countryId\":\"6252001\",\"adminCode1\":\"NH\",\"countryName\":\"United States\",\"fclName\":\"mountain,hill,rock,... \",\"countryCode\":\"US\",\"lng\":\"-71.9148\",\"fcodeName\":\"mountain\",\"toponymName\":\"Mount Cardigan\",\"fcl\":\"T\",\"name\":\"Mount Cardigan\",\"fcode\":\"MT\",\"geonameId\":5084213,\"lat\":\"43.64979\",\"adminName1\":\"New Hampshire\",\"population\":0}]}"
    static let NotJson = "Not JSON"
    
    static let jsonFromAltitudeCommunicator = "{\"srtm3\":694,\"lng\":-72.145562,\"lat\":43.720343}"
    
    static let jsonFromGoogleMapsCommunicator = "{\n   \"results\" : [\n      {\n         \"elevation\" : 614.3460083007812,\n         \"location\" : {\n            \"lat\" : 43.772333,\n            \"lng\" : -72.107691\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 317.2769165039062,\n         \"location\" : {\n            \"lat\" : 43.75391443769239,\n            \"lng\" : -72.18701631568869\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 118.7710342407227,\n         \"location\" : {\n            \"lat\" : 43.73544104864424,\n            \"lng\" : -72.26629274469713\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 317.5862426757812,\n         \"location\" : {\n            \"lat\" : 43.7169129020388,\n            \"lng\" : -72.34552020368265\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 220.0083923339844,\n         \"location\" : {\n            \"lat\" : 43.69833006715583,\n            \"lng\" : -72.42469860993879\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 395.0747985839844,\n         \"location\" : {\n            \"lat\" : 43.67969261337065,\n            \"lng\" : -72.50382788139446\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 357.7493591308594,\n         \"location\" : {\n            \"lat\" : 43.661000610153,\n            \"lng\" : -72.58290793661352\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 460.6272888183594,\n         \"location\" : {\n            \"lat\" : 43.6422541270662,\n            \"lng\" : -72.66193869479409\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 661.5969848632812,\n         \"location\" : {\n            \"lat\" : 43.6234532337661,\n            \"lng\" : -72.74092007576797\n         },\n         \"resolution\" : 19.08790397644043\n      },\n      {\n         \"elevation\" : 1287.999145507812,\n         \"location\" : {\n            \"lat\" : 43.604598,\n            \"lng\" : -72.819852\n         },\n         \"resolution\" : 19.08790397644043\n      }\n   ],\n   \"status\" : \"OK\"\n}\n"
}

struct LocationEpsilon {
    static let Distance = 0.000001
    static let Altitude = 0.1
}

func == (lhs: [CLLocation], rhs: [CLLocation]) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    for (index, lhsLocation) in enumerate(lhs) {
        if abs(lhsLocation.coordinate.latitude - rhs[index].coordinate.latitude) > LocationEpsilon.Distance {
            println("latitudes: \(lhsLocation.coordinate.latitude), \(rhs[index].coordinate.latitude)")
            return false
        }
        if abs(lhsLocation.coordinate.longitude - rhs[index].coordinate.longitude) > LocationEpsilon.Distance {
            println("longitudes: \(lhsLocation.coordinate.longitude), \(rhs[index].coordinate.longitude)")
            return false
        }
        if abs(lhsLocation.altitude - rhs[index].altitude) > LocationEpsilon.Altitude {
            println("altitudes: \(lhsLocation.altitude), \(rhs[index].altitude)")
            return false
        }
    }
    return true
}

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
}
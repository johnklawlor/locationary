//
//  GeoNamesJSONParser.swift
//  what's what
//
//  Created by John Lawlor on 3/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

struct JSONError {
    static let JSONStringIsNil = "JSONStringShouldNotBeNil"
}

struct JSONErrorCode {
    static let JSONStringIsNil = 0
}

struct ParserConstants {
    static let Error_SerializedJSONPossiblyNotADictionary = NSError(domain: "SerializedJSONStringCouldNotBeCastAsDictionary", code: 1, userInfo: nil)
    static let Error_JSONIsEmpty = NSError(domain: "Attempted to parse empty JSON string", code: 2, userInfo: nil)
}

class GeonamesJSONParser: Equatable {
    
    init() {
        
    }
    
    func buildAndReturnArrayFromJSON(json: String) -> ([AnyObject]?, NSError?) {
        if json.isEmpty {
            return (nil, ParserConstants.Error_JSONIsEmpty)
        }
        
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var error: NSError?
            let serialzedJSONDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary
            if let jsonEncodingError = error {
                return (nil, jsonEncodingError)
            }
            if let jsonDictionary = serialzedJSONDictionary {
                println("jsonDictionary is \(jsonDictionary)")
                var pointsArray = [NearbyPoint]()
                if let geonames = jsonDictionary.objectForKey("geonames") as? NSArray {
                    for aNearbyPoint in geonames {
                        let name = aNearbyPoint.objectForKey("name") as! String
                        let latitudeString = aNearbyPoint.objectForKey("lat") as! String
                        let latitude = NSNumberFormatter().numberFromString(latitudeString)?.doubleValue
                        let longitudeString = aNearbyPoint.objectForKey("lng") as! String
                        let longitude = NSNumberFormatter().numberFromString(longitudeString)?.doubleValue
                        let date = NSDate(timeIntervalSince1970: 0)
                        if latitude == nil || longitude == nil {
                            continue
                        } else {
                            let location = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude!, longitude!), altitude: -1000000, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: date)
                            let aPoint = NearbyPoint(aName: name, aLocation: location)
                            pointsArray.append(aPoint)
                        }
                    }
                    return (pointsArray, nil)
                }
                else if let elevationPointsAlongLine = jsonDictionary.objectForKey("results") as? NSArray {
                    var locationsBetweenPoints = [CLLocation]()
                    println("jsonArray is \(elevationPointsAlongLine)")
                    for elevationPoint in elevationPointsAlongLine {
                        println("elevationPoint: \(elevationPoint.isKindOfClass(NSDictionary))")
                        let elevationLong = elevationPoint.objectForKey("elevation") as! Double
                        let elevation = floor(elevationLong / 0.000001) / 1000000
                        println("elevation: \(elevation)")
                        let location = elevationPoint.objectForKey("location") as! NSDictionary
                        let latitude = location.objectForKey("lat") as! Double
                        let longitude = location.objectForKey("lng") as! Double
                        let date = NSDate(timeIntervalSince1970: 0)
                        let elevationPointLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(latitude, longitude), altitude: elevation, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: date)
                        println("elevationPoint: \(elevationPointLocation)")
                        locationsBetweenPoints.append(elevationPointLocation)
                    }
                    println("returning elevation profile: \(locationsBetweenPoints)")
                    return (locationsBetweenPoints, nil)
                }
            }
        }
        
        return ([AnyObject](), nil)
    }
}
//
//  GeoNamesJSONParser.swift
//  what's what
//
//  Created by John Lawlor on 3/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreLocation

func == (lhs: GeonamesJSONParser, rhs: GeonamesJSONParser) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

struct JSONError {
    static let JSONStringIsNil = "JSONStringShouldNotBeNil"
}

struct JSONErrorCode {
    static let JSONStringIsNil = 0
}

class GeonamesJSONParser: Equatable {
    
    init() {
        
    }
    
    func buildAndReturnArrayFromJSON(json: String) -> ([AnyObject]?, NSError?) {
        if json.isEmpty {
            let error = NSError(domain: JSONError.JSONStringIsNil, code: JSONErrorCode.JSONStringIsNil, userInfo: nil)
            return (nil, error)
        }
        
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var jsonEncodingError: NSError?
            let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonEncodingError) as! NSDictionary?
            if jsonEncodingError != nil {
                return (nil, jsonEncodingError)
            } else if jsonDictionary != nil {
                var pointsArray = [NearbyPoint]()
//                let srt = jsonDictionary!.objectForKey("srtm3") as? NSInteger
//                println("jsonDictionary is \(srt)")
                if let geonames = jsonDictionary?.objectForKey("geonames") as? NSArray {
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
                else if let altitude = jsonDictionary?.objectForKey("srtm3") as? NSInteger {
                    return ([altitude], nil)
                }
            }
        }
        
        return ([AnyObject](), nil)
    }
}
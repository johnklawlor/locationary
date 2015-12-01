//
//  GeoNamesJSONParser.swift
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

protocol GeonamesCommunicatorProvider {
    var communicator: GeonamesCommunicator? { get }
}

protocol LocationManagerDelegate {
    var didCompleteFullRequest: Bool { get set }
}

class GeonamesJSONParser: Equatable {
    
    var geonamesCommunicatorProvider: GeonamesCommunicatorProvider?
    var locationManagerDelegate: LocationManagerDelegate?
    
    init() {
        
    }
    
    func buildAndReturnArrayFromJSON(json: String) -> ([AnyObject]?, Int?, NSError?) {
        if json.isEmpty {
            return (nil, nil, ParserConstants.Error_JSONIsEmpty)
        }
        
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            do {
                let serializedJSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                if let jsonDictionary = serializedJSONDictionary {
                    var pointsArray = [NearbyPoint]()
                    
                    if let totalResultsCount = jsonDictionary.objectForKey("totalResultsCount") as? NSInteger {
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
                            return (pointsArray, totalResultsCount, nil)
                        } else {
                            // response does not have a geonames key. need to make new request
                        }
                    } else {
                        // response does not have totalResultsCount key. need to make new request
                    }
                }
            }
            catch let error as NSError {
                return (nil, nil, error)
            }
            
        }
        
        return ([AnyObject](), 0, nil)
    }
}
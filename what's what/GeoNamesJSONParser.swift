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
                var pointsArray = [NearbyPoint]()
                
                if let totalResultsCount = jsonDictionary.objectForKey("totalResultsCount") as? NSInteger {
                    if geonamesCommunicatorProvider != nil {
                        if geonamesCommunicatorProvider!.communicator != nil {
                            geonamesCommunicatorProvider!.communicator!.startRowCount += 1
                        } else {
                            println("communicator is nil")
                        }
                    } else {
                        println("provider is nil")
                    }
                    let totalPointsRetrievedAlready = geonamesCommunicatorProvider!.communicator!.startRow
                    if totalResultsCount > totalPointsRetrievedAlready {
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                            self.geonamesCommunicatorProvider!.communicator!.fetchJSONData()
                        }
                    } else {
                        locationManagerDelegate?.didCompleteFullRequest = true
                    }
                }

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
            }
        }
        
        return ([AnyObject](), nil)
    }
}
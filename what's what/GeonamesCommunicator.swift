//
//  GeonamesManager.swift
//  what's what
//
//  Created by John Lawlor on 3/27/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

protocol GeonamesCommunicatorDelegate {
    func fetchingNearbyPointsFailedWithError(error: NSError)
    func receivedNearbyPointsJSON(json: String)
}

struct CommunicatorConstants {
    static let HTTPResponseError = "GeonamesCommunicatorErrorDoman"
    static let DistanceGeonamesPointsMustFallWithin: Double = 60.0
}

class GeonamesCommunicator: NSObject, NSURLConnectionDelegate {

    var geonamesCommunicatorDelegate: GeonamesCommunicatorDelegate?

    var fetchingConnection: NSURLConnection?
    var fetchingRequest: NSURLRequest?
    var fetchingUrl: NSURL? {
        if currentLocation != nil {
            return NSURL(string: "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=\(south.format())&north=\(north.format())&west=\(west.format())&east=\(east.format())&orderby=elevation&username=jkl234&maxRows=10")
        } else {
            return nil
        }
    }
    var receivedData: NSMutableData?
    
    var currentLocation: CLLocation? {
        willSet {
            if currentLocation != nil {
                if currentLocation == newValue {
                    requestAttempts++
                } else {
                    requestAttempts = 1
                }
            } else {
                requestAttempts = 1
            }
        }
    }
    var requestAttempts = 0
    let dlat: Double = (1/110.54) * CommunicatorConstants.DistanceGeonamesPointsMustFallWithin
    var dlong: Double {
        if currentLocation != nil {
            println("returning calculated dlong")
            return CommunicatorConstants.DistanceGeonamesPointsMustFallWithin * (1/(111.32*cos(currentLocation!.coordinate.latitude*M_PI/180)))
        }
        return 0.063494
    }
    var north: Double { println("north: \(currentLocation!.coordinate.latitude + dlat)"); return currentLocation!.coordinate.latitude + dlat}
    var south: Double { println("south: \(currentLocation!.coordinate.latitude - dlat)"); return currentLocation!.coordinate.latitude - dlat }
    var east: Double { println("east: \(currentLocation!.coordinate.longitude + dlong)"); return currentLocation!.coordinate.longitude + dlong }
    var west: Double { println("west: \(currentLocation!.coordinate.longitude - dlong)"); return currentLocation!.coordinate.longitude - dlong }
    
    override init() {
        super.init()
    }
    
    func fetchGeonamesJSONData() {
        println("trying to fetch")
        if let url = fetchingUrl {
            println("fetching")
            fetchingRequest = NSURLRequest(URL: url)
            launchConnectionForRequest(fetchingRequest!)
        }
    }
    
    func launchConnectionForRequest(request: NSURLRequest) {
        self.cancelAndDiscardConnection()
        fetchingConnection = NSURLConnection(request: request, delegate: self)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        println("got response")
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 {
                let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: httpResponse.statusCode, userInfo: nil)
                geonamesCommunicatorDelegate?.fetchingNearbyPointsFailedWithError(error)
            } else {
                // TEST
                receivedData = NSMutableData()
                // TEST
            }
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("i died")
        receivedData = nil
        self.fetchingConnection = nil
        self.fetchingRequest = nil
        geonamesCommunicatorDelegate?.fetchingNearbyPointsFailedWithError(error)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        println("got data: \(receivedData)")
        if let data = receivedData {
            if let jsonString = NSString(data: receivedData!, encoding: NSUTF8StringEncoding) {
                println("calling commDelegate")
                geonamesCommunicatorDelegate?.receivedNearbyPointsJSON(jsonString as String)
            } else {
                println("encoding error")
            }
        } else {
            println("no data received")
        }
    }
    
    func cancelAndDiscardConnection() {
        fetchingConnection?.cancel()
        fetchingConnection = nil
    }
    
}

extension Double {
    func format() -> String {
        return NSString(format: "%0.6f", self) as String
    }
}
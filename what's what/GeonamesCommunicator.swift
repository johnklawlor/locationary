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
}

class GeonamesCommunicator {

    var geonamesCommunicatorDelegate: GeonamesCommunicatorDelegate?

    var fetchingConnection: NSURLConnection?
    var fetchingRequest: NSURLRequest?
    var fetchingUrl: NSURL? {
        if currentLocation != nil {
            return NSURL(string: "http://api.geonames.org/searchJSON?q=&featureCode=MT&south=\(south.format())&north=\(north.format())&west=\(west.format())&east=\(east.format())&orderby=elevation&username=jkl234")
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
    let dlat: Double = 100*(1/110.54)
    var dlong: Double {
        if currentLocation != nil {
            println("returning calculated dlong")
            return 100*(1/(111.32*cos(currentLocation!.coordinate.latitude*M_PI/180)))
        }
        return 0.063494
    }
    var north: Double { return currentLocation!.coordinate.latitude + dlat}
    var south: Double { return currentLocation!.coordinate.latitude - dlat }
    var east: Double { return currentLocation!.coordinate.longitude + dlong }
    var west: Double { return currentLocation!.coordinate.longitude - dlong }
    
    init() {
        
    }
    
    func fetchGeonamesJSONData() {
        if let url = fetchingUrl {
            fetchingRequest = NSURLRequest(URL: url)
            launchConnectionForRequest(fetchingRequest!)
        }
    }
    
    func launchConnectionForRequest(request: NSURLRequest) {
        self.cancelAndDiscardConnection()
        fetchingConnection = NSURLConnection(request: request, delegate: self)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 {
                let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: httpResponse.statusCode, userInfo: nil)
                geonamesCommunicatorDelegate?.fetchingNearbyPointsFailedWithError(error)
            }
        } else {
            receivedData = NSMutableData()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        receivedData = nil
        self.fetchingConnection = nil
        self.fetchingRequest = nil
        geonamesCommunicatorDelegate?.fetchingNearbyPointsFailedWithError(error)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if receivedData != nil {
            if let jsonString = NSString(data: receivedData!, encoding: NSUTF8StringEncoding) {
                geonamesCommunicatorDelegate?.receivedNearbyPointsJSON(jsonString as String)
            }
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
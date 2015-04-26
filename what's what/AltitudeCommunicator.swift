//
//  AltitudeCommunicator.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

protocol AltitudeCommunicatorDelegate {
    func fetchingAltitudeFailedWithError(error: NSError)
    func receivedAltitudeJSON(json: String)
}

class AltitudeCommunicator: NSObject, NSURLConnectionDataDelegate {
    var altitudeCommunicatorDelegate: AltitudeCommunicatorDelegate?
    
    var requestAttempts = 0
    var fetchingUrl: NSURL? {
        if locationOfAltitudeToFetch != nil {
            return NSURL(string: "http://api.geonames.org/srtm3JSON?lat=\(locationOfAltitudeToFetch!.coordinate.latitude)&lng=\(locationOfAltitudeToFetch!.coordinate.longitude)&username=jkl234")
        } else {
            return nil
        }
    }
    var fetchingAltitudeRequest: NSURLRequest?
    var fetchingAltitudeConnection: NSURLConnection?
    var receivedData: NSMutableData?
    
    var locationOfAltitudeToFetch: CLLocation? {
        willSet {
            if locationOfAltitudeToFetch != nil {
                if locationOfAltitudeToFetch == newValue {
                    requestAttempts++
                } else {
                    requestAttempts = 1
                }
            } else {
                requestAttempts = 1
            }
        }
    }
    
    func fetchAltitudeJSONData() {
        fetchingAltitudeRequest = NSURLRequest(URL: fetchingUrl!)
        launchConnectionForRequest(fetchingAltitudeRequest!)
    }
    
    func launchConnectionForRequest(request: NSURLRequest) {
        fetchingAltitudeConnection = NSURLConnection(request: request, delegate: self)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        receivedData = nil
        self.fetchingAltitudeConnection = nil
        self.fetchingAltitudeRequest = nil
        altitudeCommunicatorDelegate?.fetchingAltitudeFailedWithError(error)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        println("got altitude response")
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 {
                let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: httpResponse.statusCode, userInfo: nil)
                altitudeCommunicatorDelegate?.fetchingAltitudeFailedWithError(error)
            } else {
                receivedData = NSMutableData()
            }
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        println("got data")
        if receivedData != nil {
            let jsonString = NSString(data: receivedData!, encoding: NSUTF8StringEncoding)!
            altitudeCommunicatorDelegate?.receivedAltitudeJSON(jsonString as String)
        } else {
            println("altitude data is nil")
        }
    }
    
    func cancelAndDiscardConnection() {
        fetchingAltitudeConnection?.cancel()
        fetchingAltitudeConnection = nil
    }

}
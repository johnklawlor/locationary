//
//  Communicator.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

protocol CommunicatorDelegate {
    func fetchingFailedWithError(error: NSError)
    func receivedJSON(json: String)
}

class Communicator: NSObject, NSURLConnectionDataDelegate {
    var communicatorDelegate: CommunicatorDelegate?
    
    var requestAttempts = 0
    var fetchingUrl: NSURL?
    var fetchingRequest: NSURLRequest?
    var fetchingConnection: NSURLConnection?
    var receivedData: NSMutableData?
    
    func fetchJSONData() {
        fetchingRequest = NSURLRequest(URL: fetchingUrl!)
        launchConnectionForRequest(fetchingRequest!)
    }
    
    func launchConnectionForRequest(request: NSURLRequest) {
        fetchingConnection = NSURLConnection(request: request, delegate: self)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        receivedData = nil
        self.fetchingConnection = nil
        self.fetchingRequest = nil
        communicatorDelegate?.fetchingFailedWithError(error)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        println("got connection response")
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 {
                let error = NSError(domain: CommunicatorConstants.HTTPResponseError, code: httpResponse.statusCode, userInfo: nil)
                communicatorDelegate?.fetchingFailedWithError(error)
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
            communicatorDelegate?.receivedJSON(jsonString as String)
        } else {
            println("response data is nil")
        }
    }
    
    func cancelAndDiscardConnection() {
        fetchingConnection?.cancel()
        fetchingConnection = nil
    }

}
//
//  Communicator.swift
//  what's what
//
//  Created by John Lawlor on 3/31/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation
import CoreLocation

struct CommunicatorConstants {
    static let HTTPResponseError = "GeonamesCommunicatorErrorDoman"
    static let Error_NoURLToFetch = NSError(domain: "NoURLToFetch-CurrentLocationProbablyNotSet", code: 1, userInfo: nil)
}

protocol CommunicatorDelegate {
    func fetchingFailedWithError(error: NSError)
    func receivedJSON(json: String)
}

class Communicator: NSObject, NSURLConnectionDataDelegate {
    var communicatorDelegate: CommunicatorDelegate?
    
    var requestAttempts = 0
    var fetchingUrl: NSURL? {
        return nil
    }
    var fetchingRequest: NSURLRequest?
    var fetchingConnection: NSURLConnection?
    var receivedData: NSMutableData?
    
    var connectionQueue = NSOperationQueue()
    
    func fetchJSONData() {
        if let urlToFetch = fetchingUrl {
            println("requesting at \(urlToFetch)")
            fetchingRequest = NSURLRequest(URL: fetchingUrl!)
            launchConnectionForRequest(fetchingRequest!)
        } else {
            communicatorDelegate?.fetchingFailedWithError(CommunicatorConstants.Error_NoURLToFetch)
        }
    }
    
    func launchConnectionForRequest(request: NSURLRequest) {
        fetchingConnection?.cancel()
        println("launching connection")
//        fetchingConnection = NSURLConnection(request: request, delegate: self)
        fetchingConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        fetchingConnection?.setDelegateQueue(connectionQueue)
        fetchingConnection?.start()
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
                self.communicatorDelegate?.fetchingFailedWithError(error)
            } else {
                self.receivedData = NSMutableData()
            }
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        println("connection did finish loading")
        if receivedData != nil {
            println("passing json to delegate")
            let jsonString = NSString(data: receivedData!, encoding: NSUTF8StringEncoding)!
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                communicatorDelegate?.receivedJSON(jsonString as String)
            }
        } else {
            println("response data is nil")
        }
    }
    
    func cancelAndDiscardConnection() {
        fetchingConnection?.cancel()
        fetchingConnection = nil
    }

}
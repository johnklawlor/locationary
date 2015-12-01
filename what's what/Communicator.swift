//
//  Communicator.swift
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

import Foundation
import CoreLocation

struct CommunicatorConstants {
    static let HTTPResponseError = "GeonamesCommunicatorErrorDoman"
    static let Error_NoURLToFetch = NSError(domain: "NoURLToFetch-CurrentLocationProbablyNotSet", code: 1, userInfo: nil)
    static let NilDataError = NSError(domain: "NilDataError", code: 1, userInfo: nil)
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
            fetchingRequest = NSURLRequest(URL: urlToFetch)
            launchConnectionForRequest(fetchingRequest!)
        } else {
            communicatorDelegate?.fetchingFailedWithError(CommunicatorConstants.Error_NoURLToFetch)
        }
    }
    
    func launchConnectionForRequest(request: NSURLRequest) {
        fetchingConnection?.cancel()
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
        if receivedData != nil {
            let jsonString = NSString(data: receivedData!, encoding: NSUTF8StringEncoding)!
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.communicatorDelegate?.receivedJSON(jsonString as String)
            }
        } else {
            communicatorDelegate?.fetchingFailedWithError(CommunicatorConstants.NilDataError)
        }
    }
    
    func cancelAndDiscardConnection() {
        fetchingConnection?.cancel()
        fetchingConnection = nil
    }

}
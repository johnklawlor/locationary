//
//  FakeURLResponse.swift
//  what's what
//
//  Created by John Lawlor on 3/28/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import Foundation

class FakeURLResponse: NSHTTPURLResponse {

    init?(code: NSInteger) {
        super.init(URL: NSURL(), statusCode: code, HTTPVersion: nil, headerFields: nil)
    }
    
    override init(URL: NSURL, MIMEType: String?, expectedContentLength length: Int, textEncodingName name: String?) {
        super.init(URL: URL, MIMEType: MIMEType, expectedContentLength: length, textEncodingName: name)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
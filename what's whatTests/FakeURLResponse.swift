//
//  FakeURLResponse.swift
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
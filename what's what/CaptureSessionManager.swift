//
//  CaptureSessionManager.swift
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
import CoreMedia
import AVFoundation


class CaptureSessionManager {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    
    init() {
        captureSession = AVCaptureSession()
    }
    
    func addVideoPreviewLayer() {
        if captureSession != nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            if previewLayer?.connection != nil {
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            }
        }
    }
    
    func addVideoInput() {
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let videoIn = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession?.canAddInput(videoIn) == true {
                captureSession?.addInput(videoIn)
            }
        }
        catch let actualError as NSError {
            print("Couldn't create video input: \(actualError)")
        }
    }
    
    func setPreviewLayer(layerBounds: CGRect, bounds: CGRect) {
        self.previewLayer?.frame = bounds
        self.previewLayer?.bounds = layerBounds
        self.previewLayer?.position = CGPointMake(CGRectGetMidX(layerBounds),
            CGRectGetMidY(layerBounds))

    }
    
    func dealloc() {
        captureSession?.stopRunning()
    
        previewLayer = nil
        captureSession = nil
    }

}
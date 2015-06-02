//
//  CaptureSessionManager.swift
//  what's what
//
//  Created by John Lawlor on 4/18/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

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
        if videoDevice != nil {
            var error: NSError?
            let videoIn = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as? AVCaptureDeviceInput
            if let actualError = error {
                println("Couldn't create video input")
            }
            else {
                if captureSession?.canAddInput(videoIn) == true {
                    captureSession?.addInput(videoIn)
                }
                else {
                    println("Couldn't add video input")
                }
            }
        }
        else {
            println("video Device nil--Couldn't create video capture device.")
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
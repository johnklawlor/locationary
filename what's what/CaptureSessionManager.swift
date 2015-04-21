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
//            previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        }
    }
    
    func addVideoInput() {
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if videoDevice != nil {
            var error: NSError?
            let videoIn = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as? AVCaptureDeviceInput
            if error != nil {
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
            println("Couldn't create video capture device")
        }
    }
    
    func dealloc() {
        captureSession?.stopRunning()
    
        previewLayer = nil
        captureSession = nil
    }

}
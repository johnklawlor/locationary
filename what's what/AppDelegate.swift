//
//  AppDelegate.swift
//  what's what
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    struct Motion {
        static let Manager = CMMotionManager()
    }
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    
    var captureDevice: AVCaptureDevice?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var nearbyPointsViewController = NearbyPointsViewController()
        nearbyPointsViewController.locationManager = CLLocationManager()
        nearbyPointsViewController.motionManager = Motion.Manager
        nearbyPointsViewController.captureManager = CaptureSessionManager()
        var nearbyPointsManager = NearbyPointsManager(delegate: nearbyPointsViewController)
        nearbyPointsManager.communicator = GeonamesCommunicator()
        nearbyPointsManager.communicator?.geonamesCommunicatorDelegate = nearbyPointsManager
        nearbyPointsManager.parser = GeonamesJSONParser()
        // TEST
        nearbyPointsManager.parser.geonamesCommunicatorProvider = nearbyPointsManager
        // TEST
        nearbyPointsViewController.nearbyPointsManager = nearbyPointsManager

        let phoneHeight = CGFloat(UIScreen.mainScreen().bounds.width)
        let phoneWidth = CGFloat(UIScreen.mainScreen().bounds.height)
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        println("captureDevice is \(captureDevice)")
        if let retrievedDevice = captureDevice {
            
            let theFieldOfVision = retrievedDevice.activeFormat.videoFieldOfView
            let maxZoom = retrievedDevice.activeFormat.videoMaxZoomFactor
            
            nearbyPointsViewController.captureDevice = retrievedDevice

            nearbyPointsViewController.DeviceConstants = Constants(theFieldOfVision: theFieldOfVision, maxZoom: maxZoom, phoneWidth: phoneWidth, phoneHeight: phoneHeight)
            println("fieldOfVision: \(nearbyPointsViewController.DeviceConstants.fieldOfVision)")
            println("Width: \(nearbyPointsViewController.DeviceConstants.PhoneWidth)")
            println("Height: \(nearbyPointsViewController.DeviceConstants.PhoneHeight)")
        }
        
        self.navigationController = UINavigationController()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.viewControllers = [nearbyPointsViewController]

        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


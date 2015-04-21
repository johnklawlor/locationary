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

    var window: UIWindow?
    var navigationController: UINavigationController?

    struct Motion {
        static let Manager = CMMotionManager()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var nearbyPointsViewController = NearbyPointsViewController()
        var nearbyPointsManager = NearbyPointsManager()
        nearbyPointsViewController.nearbyPointsManager = nearbyPointsManager
        nearbyPointsViewController.locationManager = CLLocationManager()
        nearbyPointsViewController.motionManager = Motion.Manager
        nearbyPointsViewController.captureManager = CaptureSessionManager()

        let phoneHeight = CGFloat(UIScreen.mainScreen().bounds.width)
        let phoneWidth = CGFloat(UIScreen.mainScreen().bounds.height)
        
        let devices = AVCaptureDevice.devices()
        var captureDevice: AVCaptureDevice?
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        if let retrievedDevice = captureDevice {
            let HFOV = retrievedDevice.activeFormat.videoFieldOfView
            let VFOC = ((HFOV)/16.0)*9.0

            nearbyPointsViewController.DeviceConstants = Constants(hfov: HFOV, vfoc: VFOC, phoneWidth: phoneWidth, phoneHeight: phoneHeight)
            println("HFOV: \(nearbyPointsViewController.DeviceConstants.HFOV)")
            println("VFOV: \(nearbyPointsViewController.DeviceConstants.VFOV)")
            println("Width: \(nearbyPointsViewController.DeviceConstants.PhoneWidth)")
            println("Height: \(nearbyPointsViewController.DeviceConstants.PhoneHeight)")
        } else {
            nearbyPointsViewController.DeviceConstants = Constants(hfov: 58.04, vfoc: 32.6475, phoneWidth: phoneWidth, phoneHeight: phoneHeight)
        }
        
        self.navigationController = UINavigationController()
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


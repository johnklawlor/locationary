//
//  AppDelegate.swift
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
    
    var nearbyPointsViewController: NearbyPointsViewController?
    
    var captureDevice: AVCaptureDevice?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let defaultValue: NSNumber = 1
        let appDefaults = ["units_of_distance": defaultValue]
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        
        nearbyPointsViewController = NearbyPointsViewController()
        nearbyPointsViewController?.locationManager = CLLocationManager()
        nearbyPointsViewController?.motionManager = Motion.Manager
        nearbyPointsViewController?.captureManager = CaptureSessionManager()
        let nearbyPointsManager = NearbyPointsManager(delegate: nearbyPointsViewController!)
        nearbyPointsManager.communicator = GeonamesCommunicator()
        nearbyPointsManager.communicator?.geonamesCommunicatorDelegate = nearbyPointsManager
        nearbyPointsManager.parser = GeonamesJSONParser()
        // TEST
        nearbyPointsManager.parser.geonamesCommunicatorProvider = nearbyPointsManager
        nearbyPointsManager.parser.locationManagerDelegate = nearbyPointsViewController
        // TEST
        nearbyPointsViewController?.nearbyPointsManager = nearbyPointsManager

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
        if let retrievedDevice = captureDevice {
            
            let theFieldOfVision = retrievedDevice.activeFormat.videoFieldOfView
            let maxZoom = retrievedDevice.activeFormat.videoMaxZoomFactor
            
            nearbyPointsViewController?.captureDevice = retrievedDevice

            nearbyPointsViewController?.DeviceConstants = Constants(theFieldOfVision: theFieldOfVision, maxZoom: maxZoom, phoneWidth: phoneWidth, phoneHeight: phoneHeight)
        } else {
            nearbyPointsViewController?.DeviceConstants = Constants(theFieldOfVision: 58.04, maxZoom: 4, phoneWidth: 375.0, phoneHeight: 667.0)
        }
        
        self.navigationController = UINavigationController()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.viewControllers = [nearbyPointsViewController!]

        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        if let viewController = nearbyPointsViewController {
            
            viewController.removeProgressIndicator()
		
            viewController.didResignDuringRequest = !viewController.didCompleteFullRequest
            
            if viewController.nearbyPointsInLineOfSight != nil {
                viewController.nearbyPointsInLineOfSight! += viewController.nearbyPointsToExpand
                viewController.nearbyPointsToExpand = [NearbyPoint]()
                for nearbyPoint in viewController.nearbyPointsInLineOfSight! {
                    nearbyPoint.label.hidden = true
                }
            }
            
            if let nameLabel = viewController.nameLabel {
                nameLabel.hidden = true
            }
            
            if viewController.motionManager != nil {
                viewController.motionManager.stopAccelerometerUpdates()
            }
            // reset the video zoom values
            viewController.resetVideoZoomValues()
        }
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        if let viewController = nearbyPointsViewController {
            if viewController.motionManager != nil && viewController.locationManager != nil {
                if CLLocationManager.headingAvailable() {
                    viewController.units = NSUserDefaults.standardUserDefaults().integerForKey("units_of_distance")
                    viewController.locationManager.startUpdatingHeading()
                    viewController.motionManager.startAccelerometerUpdatesToQueue(
                        NSOperationQueue.mainQueue(),
                        withHandler: viewController.motionHandler)
                }
            }
        }
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
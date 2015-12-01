//
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
import XCTest
import CoreLocation
import CoreMotion
import AVFoundation

class AppDelegateTests: XCTestCase {
    
    var applicationDelegate: AppDelegate!
    var viewController: NearbyPointsViewController!
    var finishedLaunching: Bool!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        applicationDelegate = AppDelegate()
        applicationDelegate.window = UIWindow()
        finishedLaunching = applicationDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
        viewController = applicationDelegate.navigationController?.viewControllers.first! as! NearbyPointsViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApplicationDidFinishLaunchingReturnsTrue() {
        XCTAssertTrue(finishedLaunching == true, "applicationDidFinishLaunching should return true")
    }

    func testApplicationDidFinishLaunchingSetsViewController() {
        XCTAssertTrue(viewController.isKindOfClass(NearbyPointsViewController) == true, "appDelegate's topViewController should be a NearbyPointsViewController")
    }
    
    func testAppDelegateSetsNearbyPointsViewControllersLocationManager() {
        XCTAssertTrue(viewController.locationManager.isKindOfClass(CLLocationManager) == true, "viewController should have a CLLocationManager")
    }
    
    func testAppDelegateSetsViewControllersMotionManager() {
        XCTAssertTrue(viewController.motionManager.isKindOfClass(CMMotionManager) == true, "viewController should have a motionManager")
    }
    
    func testAppDelegatesSetViewControllersCaptureManager() {
        XCTAssertNotNil(viewController.captureManager, "appDelegate should set viewController's captureManager")
    }
    
//    func testAppDelegateSetsViewControllersDeviceConstants() {
//        XCTAssertNotNil(viewController.DeviceConstants.fieldOfVision, "FieldOfVision should be set")
//        XCTAssertNotNil(viewController.DeviceConstants.PhoneWidth, "PhoneWidth should be set")
//        XCTAssertNotNil(viewController.DeviceConstants.PhoneHeight, "PhoneHeight should be set")
//    }

    func testAppDelegatesWindowsRootViewControllerIsItsNavigationController() {
        XCTAssertTrue(applicationDelegate.window!.rootViewController == applicationDelegate.navigationController!, "appDelegate's window's rootViewController should be appDelegate's navigationController")
    }
    
    func testAppDelegateSetsViewControllersDeviceConstantsGivenADevice() {
        class MockAVCaptureDeviceFormat: AVCaptureDeviceFormat {
            override var videoFieldOfView: Float {
                return 58.0
            }
        }
        class MockVideoDevice: AVCaptureDevice {
            override class func devices() -> [AnyObject]! {
                return [MockAVCaptureDeviceFormat()]
            }
            override var activeFormat: AVCaptureDeviceFormat! {
                get {
                    return MockAVCaptureDeviceFormat()
                }
                set {
                    
                }
            }
        }
        println("MockVideoDevice() is \(MockVideoDevice())")
        applicationDelegate.captureDevice = MockVideoDevice()
//        XCTAssertEqual(viewController.DeviceConstants.HFOV, 58.0, "appDelegate should set its viewController's DeviceConstants")
    }
    
    func testAppDelegateSetsUpInitialNearbyPointsManager() {
        let nearbyPointsManager = viewController.nearbyPointsManager as NearbyPointsManager
        XCTAssertNotNil(nearbyPointsManager, "viewController should have a nearbyPointsManager")
    }
    
    func testViewControllersNearbyPointsManagerHasAGeonamesCommunicatorAndAParser() {
        let geonamesCommunicator = viewController.nearbyPointsManager.communicator as GeonamesCommunicator!
        let parser = viewController.nearbyPointsManager.parser as GeonamesJSONParser
        XCTAssertNotNil(geonamesCommunicator, "viewController's nearbyPointsManager should have a GeonamesCommunicator")
        XCTAssertNotNil(parser, "viewController's nearbyPointsManager should have a GeonamesJSONParser")
    }
    
    func testViewControllersNearbyPointsManagerIsDelegateForGeonamesCommunicator() {
        let geonamesCommunicatorDelegate = viewController.nearbyPointsManager.communicator?.geonamesCommunicatorDelegate as! NearbyPointsManager
        XCTAssertNotNil(geonamesCommunicatorDelegate, "viewController's nearbyPointsManager should be geonamesCommunicator's delegate")
    }
}

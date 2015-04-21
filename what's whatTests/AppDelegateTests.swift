//
//  AppDelegateTests.swift
//  what's what
//
//  Created by John Lawlor on 4/20/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation
import CoreMotion

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
    
    func testAppDelegateSetsViewControllersDeviceConstants() {
        XCTAssertNotNil(viewController.DeviceConstants.HFOV, "HFOV should be set")
        XCTAssertNotNil(viewController.DeviceConstants.VFOV, "VFOV should be set")
        XCTAssertNotNil(viewController.DeviceConstants.PhoneWidth, "PhoneWidth should be set")
        XCTAssertNotNil(viewController.DeviceConstants.PhoneHeight, "PhoneHeight should be set")
    }

    func testAppDelegatesWindowsRootViewControllerIsItsNavigationController() {
        println("window: \(applicationDelegate.window!.rootViewController)")
        println("nC: \(applicationDelegate.navigationController!)")
        XCTAssertTrue(applicationDelegate.window!.rootViewController == applicationDelegate.navigationController!, "appDelegate's window's rootViewController should be appDelegate's navigationController")
    }
}

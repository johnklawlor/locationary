//
//  NearbyPointsManager.swift
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

import CoreLocation
import UIKit

protocol CurrentLocationDelegate: class {
    var currentLocation: CLLocation? { get }
}

protocol NearbyPointsManagerDelegate: class {
    func fetchingFailedWithError(error: NSError)
    func assembledNearbyPointsWithoutAltitude()
    func foundNearbyPointInLineOfSight(nearbyPoint: NearbyPoint)
    var didCompleteFullRequest: Bool { get set }
}

public struct ManagerConstants {
    static let Error_ReachedMaxConnectionAttempts = NSError(domain: "ManagerReachedMaximumAllowedConnectionAttempts", code: 1, userInfo: nil)
    static let Error_NearbyPointsIsNil = NSError(domain: "ManagerNearbyPointsIsNil-NothingToFetch", code: 2, userInfo: nil)
    static let ElevationDataFilename = "us_bounded_compressed_tiled"

}

func with(queue: dispatch_queue_t, f: Void -> Void) {
    dispatch_sync(queue, f)
}

class NearbyPointsManager: NSObject, GeonamesCommunicatorDelegate, ElevationDataDelegate, CurrentLocationDelegate, GeonamesCommunicatorProvider {
    private let recentlyRetrievedNearbyPointsQueue = dispatch_queue_create("recentlyRetrievedNearbyPointsQueue", nil)
    
    var currentLocation: CLLocation? {
        didSet {
            communicator?.currentLocation = currentLocation
        }
    }
    var communicator: GeonamesCommunicator?
    var nearbyPointsJSON: String?
    var parser: GeonamesJSONParser!
    
    var nearbyPoints: [NearbyPoint]? = [NearbyPoint]()
    var recentlyRetrievedNearbyPoints = [NearbyPoint]()
    
    func appendToRecentlyRetrievedNearbyPoints(nearbyPointsToAppend: [NearbyPoint]) {
        recentlyRetrievedNearbyPoints += nearbyPointsToAppend
    }

    var prefetchError: NSError?
    var fetchingError: NSError?
    var parsingError: NSError?
    unowned var managerDelegate: NearbyPointsManagerDelegate
    
    var elevationDataManager: ElevationDataManager?
        
    var lowerDistanceLimit: CLLocationDistance! = 0
    var upperDistanceLimit: CLLocationDistance! = 100000
    
    init(delegate: NearbyPointsViewController) {
        managerDelegate = delegate
    }
    
    func getGeonamesJSONData() {
        if communicator?.requestAttempts <= 3 {
            communicator?.fetchJSONData()
        } else {
            managerDelegate.fetchingFailedWithError(ManagerConstants.Error_ReachedMaxConnectionAttempts)
        }
    }
    
    func fetchingNearbyPointsFailedWithError(error: NSError) {
        fetchingError = error
        // we should do something else here
    }
    
    func receivedNearbyPointsJSON(json: String) {
        nearbyPointsJSON = json
        // if json is empty, attempt another request?
        let (nearbyPointsArray, totalResultsCount, error) = parser.buildAndReturnArrayFromJSON(json)
        
        // TEST
        if error != nil {
            if communicator != nil {
                communicator!.currentLocation = currentLocation
                getGeonamesJSONData()
                return
            }
        }
        if let receivedNearbyPointsArray = nearbyPointsArray as? [NearbyPoint] {
            with(recentlyRetrievedNearbyPointsQueue, f: {
                self.recentlyRetrievedNearbyPoints += receivedNearbyPointsArray
				if self.communicator != nil {
					self.communicator!.startRowCount += 1
					let pointsRetrievedAlready = self.communicator!.startRow

					if totalResultsCount > pointsRetrievedAlready {
						dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
							self.communicator!.fetchJSONData()
						}
					} else {
						self.managerDelegate.didCompleteFullRequest = true
					}
				} else {
					// communicator is nil while making seconary request
				}
            })
            managerDelegate.assembledNearbyPointsWithoutAltitude()
        }
        else {
            // inform delegate that there are no points around user!
        }
    }
    
    func determineIfEachRecentlyRetrievedPointIsInLineOfSight() {

        with(recentlyRetrievedNearbyPointsQueue, f: {
            if !self.recentlyRetrievedNearbyPoints.isEmpty {
                self.determineIfEachPointIsInLineOfSight(&self.recentlyRetrievedNearbyPoints)
                
                self.nearbyPoints! += self.recentlyRetrievedNearbyPoints
                self.recentlyRetrievedNearbyPoints = [NearbyPoint]()
            }
        })
    }
    
    func determineIfEachOfAllNearbyPointsIsInLineOfSight() {
        if nearbyPoints != nil {
            determineIfEachPointIsInLineOfSight(&nearbyPoints!)
        } else {
            prefetchError = ManagerConstants.Error_NearbyPointsIsNil
        }
    }
    
    func determineIfEachPointIsInLineOfSight(inout someNearbyPoints: [NearbyPoint]) {
        for nearbyPoint in someNearbyPoints {
            calculateDistanceFromCurrentLocation(nearbyPoint)
            self.elevationDataManager!.getElevationForPoint(nearbyPoint)
        }
    }
    
    func processElevationProfileDataForPoint(nearbyPoint: NearbyPoint, elevationData: ElevationData) {
        
        if elevationData.elevation == 32678 {
            // theoretically, we should be able to throw this in the recentlRetrievedNearbyPointsQueue, and it will update the nearbyPoints array after determineIf has finished its for-loop
            // should we try to get its elevation again? should we remove it from the nearbyPoints array?
            // should we make a request to Geonames to get the elevation of the point and simply display it?
//            for (index, theNearbyPointToDelete) in enumerate(nearbyPoints!) {
//                if nearbyPoint == theNearbyPointToDelete {
//                    // should we append to an array that keeps track of the indices of nearbyPoints that need to be removed, and then remove them after for loops have finished?
//                    nearbyPoints!.removeAtIndex(index)
//                    break
//                }
//            }
        } else if elevationData.inLineOfSight == true {
            
            calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint)
            
            // we have to determine why one point had an angleToCurrentLocation of NaN
            
            updateElevationAndAngleToHorizonForPoint(nearbyPoint, elevation: elevationData.elevation, angleToHorizon: elevationData.angleToHorizon)

            let viewController = managerDelegate as! NearbyPointsViewController
            nearbyPoint.screenSizeDelegate = viewController
            
            nearbyPoint.makeLabelButton()
            
            // TEST

            nearbyPoint.labelTapDelegate = viewController
            
            managerDelegate.foundNearbyPointInLineOfSight(nearbyPoint)
        }
    }
    
    func updateElevationAndAngleToHorizonForPoint(nearbyPoint: NearbyPoint, elevation: Double, angleToHorizon: Double) {
        nearbyPoint.location = CLLocation(coordinate: nearbyPoint.location.coordinate, altitude: elevation, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: NSDate(timeIntervalSince1970: 0))
        nearbyPoint.angleToHorizon = angleToHorizon
    }
    
    func calculateDistanceFromCurrentLocation(nearbyPoint: NearbyPoint) {
        nearbyPoint.distanceFromCurrentLocation = currentLocation!.distanceFromLocation(nearbyPoint.location)
    }
    
    func calculateAbsoluteAngleWithCurrentLocationAsOrigin(nearbyPoint: NearbyPoint) {

        let y = CLLocation(coordinate: CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: nearbyPoint.location.coordinate.longitude), altitude: nearbyPoint.location.altitude, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: NSDate(timeIntervalSinceNow: 0))
        let dy = y.distanceFromLocation(nearbyPoint.location)

        // correct for discrepencies when dy is erroneously larger than distanceFromCurrentLocation
        var quotient = dy/nearbyPoint.distanceFromCurrentLocation
        quotient = quotient > 1 ? 1 : quotient
        
        if nearbyPoint.location.coordinate.longitude < currentLocation!.coordinate.longitude {
            if nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude {
                nearbyPoint.angleToCurrentLocation = 180.0 - asin(quotient)*(180.0/M_PI)
            } else {
                nearbyPoint.angleToCurrentLocation = 180.0 + asin(quotient)*(180.0/M_PI)
            }
        } else {
            if nearbyPoint.location.coordinate.latitude > currentLocation!.coordinate.latitude {
                nearbyPoint.angleToCurrentLocation = asin(quotient)*(180/M_PI)
            } else {
                nearbyPoint.angleToCurrentLocation = 360.0 - asin(quotient)*(180.0/M_PI)
            }
        }
    }
    
}
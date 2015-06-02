//
//  ElevationDataManager.swift
//  what's what
//
//  Created by John Lawlor on 6/1/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

import UIKit

struct ElevationData {
    
    init(anElevation: Double, anAngleToHorizon: Double, IsInLineOfSight: Bool) {
        elevation = anElevation
        angleToHorizon = anAngleToHorizon
        inLineOfSight = IsInLineOfSight
    }
    
    var elevation: Double
    var angleToHorizon: Double
    var inLineOfSight: Bool
}

protocol ElevationDataDelegate: class {
    func processElevationProfileDataForPoint(nearbyPoint: NearbyPoint, elevationData: ElevationData)
}

class ElevationDataManager {
    weak var dataDelegate: ElevationDataDelegate?
    weak var currentLocationDelegate: CurrentLocationDelegate?
    
    func getElevationForPoint(nearbyPoint: NearbyPoint) {
        
        if currentLocationDelegate != nil && dataDelegate != nil {
            let nearbyPointElevationData = GDALWrapper.getElevationAtLatitude(currentLocationDelegate!.currentLocation!.coordinate.latitude, currentLongitude: currentLocationDelegate!.currentLocation!.coordinate.longitude, currentAltitude: currentLocationDelegate!.currentLocation!.altitude, nearbyPointLatitude: nearbyPoint.location.coordinate.latitude, nearbyPointLongitude: nearbyPoint.location.coordinate.longitude, distanceFromCurrentLocation: nearbyPoint.distanceFromCurrentLocation)
            
            let elevationData = ElevationData(anElevation: nearbyPointElevationData.elevation, anAngleToHorizon: nearbyPointElevationData.angleToHorizon, IsInLineOfSight: nearbyPointElevationData.inLineOfSight)
            
            dataDelegate!.processElevationProfileDataForPoint(nearbyPoint, elevationData: elevationData)
        }
    }
}

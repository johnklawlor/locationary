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
        
        let currentLatitude = currentLocationDelegate!.currentLocation!.coordinate.latitude
        let currentLongitude = currentLocationDelegate!.currentLocation!.coordinate.longitude
        let currentAltitude = currentLocationDelegate!.currentLocation!.altitude
        
//        println("altitude: \(currentAltitude)")
//        println("distanceFromCurrentLocation: \(nearbyPoint.distanceFromCurrentLocation)")
        
        if currentLocationDelegate != nil && dataDelegate != nil {
            let nearbyPointElevationData = GDALWrapper.getElevationAtLatitude(currentLatitude, currentLongitude: currentLongitude, currentAltitude: currentAltitude, nearbyPointLatitude: nearbyPoint.location.coordinate.latitude, nearbyPointLongitude: nearbyPoint.location.coordinate.longitude, distanceFromCurrentLocation: nearbyPoint.distanceFromCurrentLocation)
            
            let elevationData = ElevationData(anElevation: nearbyPointElevationData.elevation, anAngleToHorizon: nearbyPointElevationData.angleToHorizon, IsInLineOfSight: nearbyPointElevationData.inLineOfSight)
            
//            println("elevationData: \(elevationData)")
            
            dataDelegate!.processElevationProfileDataForPoint(nearbyPoint, elevationData: elevationData)
        }
    }
}

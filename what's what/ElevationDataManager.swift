//
//  ElevationDataManager.swift
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
    
    var gdalManager: TheGDALWrapper?
    
    func getElevationForPoint(nearbyPoint: NearbyPoint) {
        
        let currentLatitude = currentLocationDelegate!.currentLocation!.coordinate.latitude
        let currentLongitude = currentLocationDelegate!.currentLocation!.coordinate.longitude
        let currentAltitude = currentLocationDelegate!.currentLocation!.altitude
        
        if currentLocationDelegate != nil && dataDelegate != nil {
            // TEST
            if let nearbyPointElevationData = gdalManager?.elevationAtCurrentLatitude(currentLatitude, currentLongitude: currentLongitude, currentAltitude: currentAltitude, nearbyPointLatitude: nearbyPoint.location.coordinate.latitude, nearbyPointLongitude: nearbyPoint.location.coordinate.longitude, distanceFromCurrentLocation: nearbyPoint.distanceFromCurrentLocation) {
            
                let elevationData = ElevationData(anElevation: nearbyPointElevationData.elevation, anAngleToHorizon: nearbyPointElevationData.angleToHorizon, IsInLineOfSight: nearbyPointElevationData.inLineOfSight)
            
            dataDelegate!.processElevationProfileDataForPoint(nearbyPoint, elevationData: elevationData)
            }
        }
    }
}

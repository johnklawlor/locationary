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
    
    func getElevationForPoint(nearbyPoint: NearbyPoint) {
        
    }
}

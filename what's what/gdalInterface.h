//
//  gdalInterface.h
//  what's what
//
//  Created by John Lawlor on 6/2/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#ifndef __what_s_what__gdalInterface__
#define __what_s_what__gdalInterface__

#include <stdio.h>

struct NearbyPointElevationData {
    double elevation;
    double angleToHorizon;
    bool inLineOfSight;
};

struct NearbyPointElevationData getNearbyPointElevationAndDetermineIfInLineOfSight (double currentLatitude, double currentLongitude, double currentAltitude, double nearbyPointLatitude, double nearbyPointLongitude, double distanceBetweenTwoPoints, const char *pathToDEMData);

#endif /* defined(__what_s_what__gdalInterface__) */

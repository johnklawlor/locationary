//
//  CNearbyPointElevationData.h
//  gdal
//
//  Created by John Lawlor on 6/7/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#ifndef gdal_CNearbyPointElevationData_h
#define gdal_CNearbyPointElevationData_h

struct NearbyPointElevationData {
    double elevation;
    double angleToHorizon;
    bool inLineOfSight;
};

#endif

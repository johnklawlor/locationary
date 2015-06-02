//
//  GDALWrapper.c
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#import "GDALWrapper.h"

@implementation GDALWrapper

+ (NearbyPointElevationData) getElevationAtLatitude: (double)currentLatitude currentLongitude: (double)currentLongitude currentAltitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceFromCurrentLocation: (double) distanceFromCurrentLocation {
    
    // we have to inspect the coordinates and open the proper DEM file
    NSString *pathToDEMData = [[NSBundle mainBundle] pathForResource: @"us_150max_bounding" ofType: @"tif"];
    
    // i believe we want to make a call to the gdalLocating.h function here
    
    const char *cPathToDEMData = [pathToDEMData cStringUsingEncoding:NSASCIIStringEncoding];
    
    return getNearbyPointElevationAndDetermineIfInLineOfSight(currentLatitude, currentLongitude, currentAltitude, nearbyPointLatitude, nearbyPointLongitude, distanceFromCurrentLocation, cPathToDEMData);
}

@end


//
//  GDALWrapper.c
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#import "ObjC+GDAL.h"

@implementation ObjCGDAL {
GDALDataset* elevationDataset;
}

- (void) getGDALDataset:(NSString*) gdalFilename {
    
    NSString *pathToDEMData = [[NSBundle mainBundle] pathForResource: gdalFilename ofType: @"tif"];
    
    NSLog(@"pathToDEMData: %@", pathToDEMData);
    
    const char *cPathToDEMData = [pathToDEMData cStringUsingEncoding:NSASCIIStringEncoding];
    
    elevationDataset = getGDALDataset(cPathToDEMData);
}

- (NearbyPointElevationData) getElevationAtLatitude: (double)currentLatitude longitude: (double)currentLongitude altitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceBetweenTwoPoints: (double) distanceBetweenTwoPoints {
    
    return getNearbyPointElevationAndDetermineIfInLineOfSight(currentLatitude, currentLongitude, currentAltitude, nearbyPointLatitude, nearbyPointLongitude, distanceBetweenTwoPoints, elevationDataset);
}

@end


//
//  GDALWrapper.c
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#import "GDALWrapper.h"

#import "ObjC+GDAL.h"

@implementation GDALWrapper {
    ObjCGDAL *gdalGetter;
}

- (void) createGDALGetter {
    gdalGetter = [[ObjCGDAL alloc] init];
}

- (void) openGDALFile:(NSString*) gdalFilename {
    
    [self createGDALGetter];
    
    [gdalGetter getGDALDataset: gdalFilename];
}

- (NearbyPointElevationData) elevationAtCurrentLatitude: (double)currentLatitude currentLongitude: (double)currentLongitude currentAltitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceFromCurrentLocation: (double) distanceBetweenTwoPoints {
    
    return [gdalGetter getElevationAtLatitude:currentLatitude longitude:currentLongitude altitude:currentAltitude nearbyPointLatitude:nearbyPointLatitude nearbyPointLongitude:nearbyPointLongitude distanceBetweenTwoPoints:distanceBetweenTwoPoints];
}

@end


//
//  GDALWrapper.h
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include "CNearbyPointElevationData.h"

@interface TheGDALWrapper : NSObject

- (void) openGDALFile:(NSString*) gdalFilename;

- (struct NearbyPointElevationData) elevationAtCurrentLatitude: (double)currentLatitude currentLongitude: (double)currentLongitude currentAltitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceFromCurrentLocation: (double) distanceBetweenTwoPoints;

@end
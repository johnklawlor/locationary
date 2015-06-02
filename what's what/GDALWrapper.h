//
//  GDALWrapper.h
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "gdalInterface.h"

@interface GDALWrapper : NSObject

+ (struct NearbyPointElevationData) getElevationAtLatitude: (double)currentLatitude currentLongitude: (double)currentLongitude currentAltitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceFromCurrentLocation: (double) distanceBetweenTwoPoints;

@end
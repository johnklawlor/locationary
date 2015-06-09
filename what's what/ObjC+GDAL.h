//
//  GDALWrapper.h
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "gdalLocating.h"

@interface ObjCGDAL : NSObject

- (void) getGDALDataset:(NSString*) gdalFilename;

- (struct NearbyPointElevationData) getElevationAtLatitude: (double)currentLatitude longitude: (double)currentLongitude altitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceBetweenTwoPoints: (double) distanceBetweenTwoPoints;

@end
//
//  gdalLocating.h
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#ifndef __gdal__gdalLocating__
#define __gdal__gdalLocating__

#include <stdio.h>

#include "gdal_priv.h"
#include "cpl_conv.h"

#include "CNearbyPointElevationData.h"

GDALDataset* getGDALDataset(const char *pathToDEMData);

struct NearbyPointElevationData getNearbyPointElevationAndDetermineIfInLineOfSight (double currentLatitude, double currentLongitude, double currentAltitude, double nearbyPointLatitude, double nearbyPointLongitude, double distanceBetweenTwoPoints, GDALDataset* elevationDataset);

#endif /* defined(__gdal__gdalLocating__) */

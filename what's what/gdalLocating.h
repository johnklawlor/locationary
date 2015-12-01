//
//  gdalLocating.h
//  Locationary
//
//  Created by John Lawlor on 3/18/15.
//  Copyright (c) 2015 John Lawlor. All rights reserved.
//
//  This file is part of Locationary.
//
//  Locationary is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Locationary is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef __gdal__gdalLocating__
#define __gdal__gdalLocating__

#include <stdio.h>

#include "gdal_priv.h"
#include "cpl_conv.h"

#include "CNearbyPointElevationData.h"

GDALDataset* getGDALDataset(const char *pathToDEMData);

struct NearbyPointElevationData getNearbyPointElevationAndDetermineIfInLineOfSight (double currentLatitude, double currentLongitude, double currentAltitude, double nearbyPointLatitude, double nearbyPointLongitude, double distanceBetweenTwoPoints, GDALDataset* elevationDataset);

#endif /* defined(__gdal__gdalLocating__) */

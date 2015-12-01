//
//  GDALWrapper.c
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

- (NearbyPointElevationData) getElevationAtCurrentLatitude: (double)currentLatitude currentLongitude: (double)currentLongitude currentAltitude: (double) currentAltitude nearbyPointLatitude: (double)nearbyPointLatitude nearbyPointLongitude: (double)nearbyPointLongitude distanceBetweenTwoPoints: (double) distanceBetweenTwoPoints {
    
    return getNearbyPointElevationAndDetermineIfInLineOfSight(currentLatitude, currentLongitude, currentAltitude, nearbyPointLatitude, nearbyPointLongitude, distanceBetweenTwoPoints, elevationDataset);
}

@end


//
//  gdalLocating.cpp
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

#include "gdalLocating.h"

#include "gdal_priv.h"
#include "cpl_conv.h"

const double UPPER_LEFT_LONG = -180.0001389;
const double UPPER_LEFT_LAT = 71.3915278;
const double PIXEL_SIZE = 0.008333333333333;

double getXInPixelCoordinates(double nearbyPointLongitude) {
    return fabs((UPPER_LEFT_LONG - nearbyPointLongitude) / PIXEL_SIZE);
}

double getYInPixelCoordinates(double nearbyPointLatitude) {
    return fabs((UPPER_LEFT_LAT - nearbyPointLatitude) / PIXEL_SIZE);
}

GDALDataset* getGDALDataset(const char *pathToDEMData) {
    
    GDALAllRegister();
    
    return (GDALDataset *) GDALOpen(pathToDEMData, GA_ReadOnly);
}

double adjustForEarthCurvature(double distanceFromCurrentLocation) {
    return distanceFromCurrentLocation/1000 * 0.1254658385 * 4;
}

NearbyPointElevationData getNearbyPointElevationAndDetermineIfInLineOfSight (double currentLatitude, double currentLongitude, double currentAltitude, double nearbyPointLatitude, double nearbyPointLongitude, double distanceBetweenTwoPoints, GDALDataset* elevationDataset) {
    
    NearbyPointElevationData nearbyPointElevationData;
    GDALRasterBand  *elevationBand;
    elevationBand = elevationDataset->GetRasterBand(1);
    double adfPixel[2];
    
    
    
    double nearbyPointPixelX = getXInPixelCoordinates(nearbyPointLongitude);
    double nearbyPointPixelY = getYInPixelCoordinates(nearbyPointLatitude);
    
    if( GDALRasterIO( elevationBand, GF_Read, nearbyPointPixelX, nearbyPointPixelY, 1, 1, adfPixel, 1, 1, GDT_CFloat64, 0, 0) == CE_None ) {
        nearbyPointElevationData.elevation = adfPixel[0];
    }
    
    nearbyPointElevationData.inLineOfSight = true;
    
    double currentPixelX = getXInPixelCoordinates(currentLongitude);
    double currentPixelY = getYInPixelCoordinates(currentLatitude);
    
    double dx = currentPixelX - nearbyPointPixelX;
    double dy = currentPixelY - nearbyPointPixelY;
    double a = dy/dx;
    
    double sumX = currentPixelX + nearbyPointPixelX;
    double sumY = currentPixelY + nearbyPointPixelY;
    double productX = sumX * a;
    double b = (sumY - productX) / 2;
    
    double distanceAwayToStartCalculations = 2000;
    double sampleDistance = 250.0;
    const double samplePoints = distanceBetweenTwoPoints/sampleDistance;
    double increment = (nearbyPointPixelX - currentPixelX)/samplePoints;
    
    double heightToSubtract = adjustForEarthCurvature(distanceBetweenTwoPoints);
    double altitudeDifference = nearbyPointElevationData.elevation - currentAltitude - heightToSubtract;
    double angleToNearbyPoint = atan(altitudeDifference / distanceBetweenTwoPoints);
    nearbyPointElevationData.angleToHorizon = angleToNearbyPoint * (180.0/M_PI);
//    printf("nearbyPointElevation: %f \n", nearbyPointElevationData.elevation);
//    printf("currentAltitude: %f \n", currentAltitude);
//    printf("%f \n", altitudeDifference);
//    printf("a: %f \n", distanceBetweenTwoPoints);
//    printf("angleToNearbyPoint: %f \n", angleToNearbyPoint);
    

    double numShort = distanceAwayToStartCalculations/sampleDistance;
    int iteration = int(numShort);
    
    double samplePointX;
    double samplePointY;
    
//    printf("samplePointX: %f \n", samplePointX);
//    printf("nearbyPointX: %f \n", nearbyPointPixelX);
//    printf("increment: %f \n", increment);
    
    for (samplePointX = currentPixelX + iteration*increment; 1 < 2; samplePointX += increment) {
        if (currentPixelX < nearbyPointPixelX) {
            if (samplePointX + (numShort+1)*increment > nearbyPointPixelX) {
                break;
            }
        } else {
            if (samplePointX + (numShort+1)*increment < nearbyPointPixelX) {
                break;
            }
        }
        
        samplePointY = a * samplePointX + b;
        
        if( GDALRasterIO( elevationBand, GF_Read, samplePointX, samplePointY, 1, 1, adfPixel, 1, 1, GDT_CFloat64, 0, 0) == CE_None ) {
            double samplePointElevation = adfPixel[0];
            double distanceToSamplePoint = sampleDistance * iteration;
            heightToSubtract = 0;
            //adjustForEarthCurvature(distanceToSamplePoint);
            double samplePointAltitudeDifference = samplePointElevation - heightToSubtract - currentAltitude;
            double angleToSamplePoint = atan(samplePointAltitudeDifference / (distanceToSamplePoint));
            
//            printf("iteration: %d \n", iteration);
//            printf("sampleElevation: %f \n", samplePointElevation);
//            printf("%f \n", samplePointAltitudeDifference);
//            printf("sampleDistance * iteration: %f \n", sampleDistance * iteration);
//            printf("sampleCoordinates: %f, %f \n", UPPER_LEFT_LAT-samplePointY*PIXEL_SIZE, UPPER_LEFT_LONG+samplePointX*PIXEL_SIZE);
//            printf("angleToSamplePoint: %f \n", angleToSamplePoint);
            
            if( angleToSamplePoint > angleToNearbyPoint ){
                nearbyPointElevationData.inLineOfSight = false;
                break;
            }
        }
        iteration += 1;
    }
    
    return nearbyPointElevationData;
}
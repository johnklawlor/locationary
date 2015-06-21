//
//  gdalLocating.cpp
//  gdal
//
//  Created by John Lawlor on 5/19/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#include "gdalLocating.h"

#include "gdal_priv.h"
#include "cpl_conv.h"

const double UPPER_LEFT_LONG = -124.850138888888893;
const double UPPER_LEFT_LAT = 49.387361111111112;
const double PIXEL_SIZE = 0.004166666666667;

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
    
    const double samplePoints = distanceBetweenTwoPoints/1000.0;
    
    
    double increment = (nearbyPointPixelX - currentPixelX)/samplePoints;
    
    
    double altitudeDifference = nearbyPointElevationData.elevation - currentAltitude;
    //    printf("nearbyPointElevation: %d \n", nearbyPointElevationAndLineOfSight.elevation);
    //    printf("currentAltitude: %f \n", currentAltitude);
    //    printf("o: %f \n", altitudeDifference);
    //    printf("a: %f \n", distanceBetweenTwoPoints);
    double angleToNearbyPoint = atan(altitudeDifference / distanceBetweenTwoPoints);
    //    printf("angleToNearbyPoint: %f \n", angleToNearbyPoint);
    nearbyPointElevationData.angleToHorizon = angleToNearbyPoint * (180.0/M_PI);
    
    double sampleDistance = 1000.0;
    //    printf("sampleDistance: %f \n", sampleDistance);
    int iteration = 1;
    
    double samplePointX;
    double samplePointY;
    
    samplePointX = currentPixelX+increment;
    
//    printf("samplePointX: %f \n", samplePointX);
//    printf("nearbyPointX: %f \n", nearbyPointPixelX);
//    printf("increment: %f \n", increment);
    
    for (samplePointX = currentPixelX+increment; 1 < 2; samplePointX += increment) {
        if (currentPixelX < nearbyPointPixelX) {
            if (samplePointX+increment > nearbyPointPixelX) {
                break;
            }
        } else {
            if (samplePointX+increment < nearbyPointPixelX) {
                break;
            }
        }
        
        samplePointY = a * samplePointX + b;
        
        if( GDALRasterIO( elevationBand, GF_Read, samplePointX, samplePointY, 1, 1, adfPixel, 1, 1, GDT_CFloat64, 0, 0) == CE_None ) {
            double samplePointElevation = adfPixel[0];
            double samplePointAltitudeDifference = samplePointElevation - currentAltitude;
            double angleToSamplePoint = atan(samplePointAltitudeDifference / (sampleDistance * iteration));
            
            //            printf("iteration: %d ", iteration);
            //            printf("sampleElevation: %f \n", samplePointElevation);
            //            printf("altitudeDifference: %f \n", samplePointAltitudeDifference);
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
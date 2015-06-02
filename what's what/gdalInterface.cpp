//
//  gdalInterface.cpp
//  what's what
//
//  Created by John Lawlor on 6/2/15.
//  Copyright (c) 2015 johnnylaw. All rights reserved.
//

#include "gdalInterface.h"

#include "gdal_priv.h"
#include "cpl_conv.h"

const double UPPER_LEFT_LONG = -124.850138888888893;
const double UPPER_LEFT_LAT = 49.387361111111112;
const double PIXEL_SIZE = 0.004166666666667;
const double SAMPLE_POINTS = 10.0;

double getXInPixelCoordinates(double nearbyPointLongitude) {
    return fabs((UPPER_LEFT_LONG - nearbyPointLongitude) / PIXEL_SIZE);
}

double getYInPixelCoordinates(double nearbyPointLatitude) {
    return fabs((UPPER_LEFT_LAT - nearbyPointLatitude) / PIXEL_SIZE);
}

NearbyPointElevationData getNearbyPointElevationAndDetermineIfInLineOfSight (double currentLatitude, double currentLongitude, double currentAltitude, double nearbyPointLatitude, double nearbyPointLongitude, double distanceBetweenTwoPoints, const char *pathToDEMData) {
    
    NearbyPointElevationData nearbyPointElevationData;
    
    GDALDataset *poDataset;
    
    GDALAllRegister();
    
    // we have to inspect the coordinates and open the proper DEM file
    
    poDataset = (GDALDataset *) GDALOpen(pathToDEMData, GA_ReadOnly);
    if( poDataset == NULL )
    {
        printf("Unable to open gdaldataset at path %s \n", pathToDEMData);
    }
    
    
    
    GDALRasterBand  *elevationBand;
    elevationBand = poDataset->GetRasterBand(1);
    
    
    
    double adfPixel[2];
    
    
    
    double nearbyPointPixelX = getXInPixelCoordinates(nearbyPointLongitude);
    double nearbyPointPixelY = getYInPixelCoordinates(nearbyPointLatitude);
    
    if( GDALRasterIO( elevationBand, GF_Read, nearbyPointPixelX, nearbyPointPixelY, 1, 1, adfPixel, 1, 1, GDT_CFloat64, 0, 0) == CE_None ) {
        CPLString osValue;
        osValue.Printf( "Killington elevation: %.15g", adfPixel[0] );
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
    
    
    double increment = (nearbyPointPixelX - currentPixelX)/SAMPLE_POINTS;
    
    
    double altitudeDifference = nearbyPointElevationData.elevation - currentAltitude;
    //    printf("nearbyPointElevation: %d \n", nearbyPointElevationAndLineOfSight.elevation);
    //    printf("currentAltitude: %f \n", currentAltitude);
    //    printf("o: %f \n", altitudeDifference);
    //    printf("a: %f \n", distanceBetweenTwoPoints);
    double angleToNearbyPoint = atan(altitudeDifference / distanceBetweenTwoPoints);
    //    printf("angleToNearbyPoint: %f \n", angleToNearbyPoint);
    nearbyPointElevationData.angleToHorizon = angleToNearbyPoint * (180.0/M_PI);
    
    double sampleDistance = distanceBetweenTwoPoints/SAMPLE_POINTS;
    //    printf("sampleDistance: %f \n", sampleDistance);
    int iteration = 1;
    
    double samplePointX;
    int samplePointY;
    
    for (samplePointX = currentPixelX+increment; abs((int)samplePointX - (int)nearbyPointPixelX) > 0; samplePointX += increment) {
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
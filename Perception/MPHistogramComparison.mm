//
//  MPHistogramComparison.m
//  Perception
//
//  Created by Matias Piipari on 12/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <vector>
#import <iostream>

#import <stdio.h>
#import <opencv2/core.hpp>

#import "NSImage+OpenCV.h"
#import "MPHistogramComparison.h"

using namespace cv;
using namespace std;

// adapted from http://study.marearts.com/2014/11/opencv-emdearth-mover-distance-example.html

@interface MPHistogramComparison ()
@end

@implementation MPHistogramComparison

- (instancetype)initWithHueBinCount:(int)hueBinCount saturationBinCount:(int)saturationBinCount {
    self = [super init];
    
    if (self) {
        _hueBinCount = hueBinCount;
        _saturationBinCount = saturationBinCount;
    }
    
    return self;
}

+ (NSData *)HSBHistogramForImage:(CGImageRef)image
                     hueBinCount:(NSUInteger)hueBinCount
              saturationBinCount:(NSUInteger)saturationBinCount {
    cv::Mat imgMat = matRepresentationColorForCGImage(image);
    cv::UMat img = imgMat.getUMat(ACCESS_READ);
    int channels[] = { 0,  1 };
    int histSize[] = { (int)hueBinCount, (int)saturationBinCount };
    float hranges[] = { 0, 180 };
    float sranges[] = { 0, 255 };
    const float* ranges[] = { hranges, sranges};

    Mat patch_HSV;
    MatND Hist;
    
    cvtColor(img, patch_HSV, CV_BGR2HSV);
    calcHist(&patch_HSV, 1, channels,  Mat(), // do not use mask
             Hist, 2, histSize, ranges,
             true, // the histogram is uniform
             false);
    normalize(Hist, Hist,  0, 1, CV_MINMAX);
    
    int numrows = hueBinCount * saturationBinCount;
    
    Mat sig(numrows, 3, CV_32FC1);
    for (int h=0, hbins = hueBinCount; h < hbins; h++) {
        for (int s=0, sbins = saturationBinCount; s < sbins; ++s) {
            int row = h * sbins + s;
            float binval = Hist.at<float>(h,s);
            sig.at<float>(row, 0) = binval;
            sig.at<float>(row, 1) = h;
            sig.at<float>(row, 2) = s;
        }
    }
    
    size_t dataSize = sizeof(float) * numrows * 3;
    float *data = (float *)malloc(dataSize);
    for (int h=0, hbins = hueBinCount; h < hbins; h++) {
        for (int s=0, sbins = saturationBinCount; s < sbins; ++s) {
            int row = h * sbins + s;
            float binval = Hist.at<float>(h,s);
            data[row + 0] = binval;
            data[row + 1] = h;
            data[row + 2] = s;
        }
    }

    return [NSData dataWithBytesNoCopy:data length:dataSize freeWhenDone:YES];
}

+ (cv::Mat)matrixFromFloatData:(NSData *)data dimensions:(MPMatrixDimensions)size {
    Mat sig((int)size.rows, (int)size.cols, CV_32FC1, (void *)data.bytes);
    return sig;
}

+ (float)earthMoverDistanceBetween:(CGImageRef)image
                          andImage:(CGImageRef)otherImage
                       hueBinCount:(int)hueBinCount
                saturationBinCount:(int)saturationBinCount
{
    //read 2 images for histogram comparing
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    cv::Mat img1Mat = matRepresentationColorForCGImage(image);
    cv::Mat img2Mat = matRepresentationColorForCGImage(otherImage);
    cv::UMat imgA = img1Mat.getUMat(ACCESS_READ);
    cv::UMat imgB = img2Mat.getUMat(ACCESS_READ);
    
    //variables preparing
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    int channels[] = { 0,  1 };
    int histSize[] = { hueBinCount, saturationBinCount };
    float hranges[] = { 0, 180 };
    float sranges[] = { 0, 255 };
    const float* ranges[] = { hranges, sranges};
    
    Mat patch_HSV;
    MatND HistA, HistB;
    
    //cal histogram & normalization
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    cvtColor(imgA, patch_HSV, CV_BGR2HSV);
    calcHist(&patch_HSV, 1, channels,  Mat(), // do not use mask
             HistA, 2, histSize, ranges,
             true, // the histogram is uniform
             false);
    normalize(HistA, HistA,  0, 1, CV_MINMAX);
    
    cvtColor(imgB, patch_HSV, CV_BGR2HSV);
    calcHist(&patch_HSV, 1, channels,  Mat(),// do not use mask
             HistB, 2, histSize, ranges,
             true, // the histogram is uniform
             false);
    normalize(HistB, HistB, 0, 1, CV_MINMAX);
    
    int numrows = hueBinCount * saturationBinCount;
    
    Mat sig1(numrows, 3, CV_32FC1);
    Mat sig2(numrows, 3, CV_32FC1);
    
    for (int h=0, hbins = hueBinCount; h < hbins; h++) {
        for (int s=0, sbins = saturationBinCount; s < sbins; ++s) {
            float binval = HistA.at< float>(h,s);
            sig1.at< float>( h*sbins + s, 0) = binval;
            sig1.at< float>( h*sbins + s, 1) = h;
            sig1.at< float>( h*sbins + s, 2) = s;
            
            binval = HistB.at< float>(h,s);
            sig2.at< float>( h*sbins + s, 0) = binval;
            sig2.at< float>( h*sbins + s, 1) = h;
            sig2.at< float>( h*sbins + s, 2) = s;
        }
    }
    
    float emd = cv::EMD(sig1, sig2, CV_DIST_L2); //emd 0 is best matching.
    return emd;
}

MPMatrixDimensions MPMakeMatrixDimensions(NSUInteger rows, NSUInteger cols) {
    MPMatrixDimensions dim;
    dim.rows = rows;
    dim.cols = cols;
    return dim;
}

+ (float)earthMoverDistanceBetweenHistogram:(nonnull NSData *)histogramA
                               andHistogram:(nonnull NSData *)histogramB
                                hueBinCount:(NSUInteger)hueBinCount
                         saturationBinCount:(NSUInteger)saturationBinCount {
    
    Mat sig1 = [self matrixFromFloatData:histogramA dimensions:MPMakeMatrixDimensions((hueBinCount * saturationBinCount), 3)];
    Mat sig2 = [self matrixFromFloatData:histogramB dimensions:MPMakeMatrixDimensions((hueBinCount * saturationBinCount), 3)];
    
    float emd = cv::EMD(sig1, sig2, CV_DIST_L2); //emd 0 is best matching.
    
    histogramA = nil;
    histogramB = nil;
    
    return emd;
}

@end

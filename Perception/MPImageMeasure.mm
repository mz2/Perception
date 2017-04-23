//
//  MPLaplacian.m
//  Perception
//
//  Created by Matias Piipari on 23/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//


#import <vector>
#import <iostream>

#import <stdio.h>
#import <opencv2/core.hpp>
#import <opencv2/imgproc/imgproc.hpp>

#import "NSImage+OpenCV.h"

#import "MPImageMeasure.h"

// from http://stackoverflow.com/questions/7765810/is-there-a-way-to-detect-if-an-image-is-blurry

@implementation MPImageMeasure

+ (double)modifiedLaplacianOfImage:(nonnull CGImageRef)cgImage
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    return [self modifiedLaplacianOfImageMatrix:image];
}

+ (double)modifiedLaplacianOfImageMatrix:(const cv::Mat &)image
{
    cv::Mat M = (cv::Mat_<double>(3, 1) << -1, 2, -1);
    cv::Mat G = cv::getGaussianKernel(3, -1, CV_64F);
    
    cv::Mat Lx;
    cv::sepFilter2D(image, Lx, CV_64F, M, G);
    
    cv::Mat Ly;
    cv::sepFilter2D(image, Ly, CV_64F, G, M);
    
    cv::Mat FM = cv::abs(Lx) + cv::abs(Ly);
    
    double focusMeasure = cv::mean(FM).val[0];
    return focusMeasure;
}

+ (double)laplacianVarianceOfImage:(nonnull CGImageRef)cgImage
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    return [self laplacianVarianceOfImageMatrix:image];
}

+ (double)laplacianVarianceOfImageMatrix:(const cv::Mat &)image
{
    cv::Mat laplacian;
    Laplacian(image, laplacian, CV_16S, 3, 1, 0, cv::BORDER_DEFAULT);
    
    cv::Scalar mu, sigma;
    cv::meanStdDev(laplacian, mu, sigma);
    
    return sigma.val[0] * sigma.val[0];
}

+ (double)tenengradScoreOfImage:(nonnull CGImageRef)cgImage kernelSize:(int)ksize
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    return [self tenengradScoreOfImageMatrix:image kernelSize:ksize];
}

+ (double)tenengradScoreOfImageMatrix:(const cv::Mat &)image kernelSize:(int)ksize
{
    cv::Mat Gx, Gy;
    cv::Sobel(image, Gx, CV_64F, 1, 0, ksize);
    cv::Sobel(image, Gy, CV_64F, 0, 1, ksize);
    
    cv::Mat FM = Gx.mul(Gx) + Gy.mul(Gy);
    
    double focusMeasure = cv::mean(FM).val[0];
    return focusMeasure;
}

+ (double)normalizedGraylevelVarianceOfImage:(nonnull CGImageRef)cgImage
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    return [self normalizedGraylevelVarianceOfImageMatrix:image];
}

+ (double)normalizedGraylevelVarianceOfImageMatrix:(const cv::Mat &)image
{
    cv::Scalar mu, sigma;
    cv::meanStdDev(image, mu, sigma);
    double focusMeasure = (sigma.val[0]*sigma.val[0]) / mu.val[0];
    return focusMeasure;
}

+ (double)cannyEdgePixelFractionOfImage:(nonnull CGImageRef)cgImage
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    
    cv::Mat edges;
    cv::Mat thresholded;
    double otsu_thresh_val = cv::threshold(image, thresholded, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    double high_thresh_val  = otsu_thresh_val;
    double lower_thresh_val = otsu_thresh_val * 0.5;

    cv::Canny(image, edges, lower_thresh_val, high_thresh_val);
    
    int nCountCanny = cv::countNonZero(edges);
    double dSharpness = nCountCanny / (image.cols * image.rows);
    return dSharpness;
}

+ (NSArray<NSNumber *> *)gradientOrientationHistogramOfImage:(nonnull CGImageRef)cgImage
                                             sobelKernelSize:(NSUInteger)ksize
                                                    binCount:(NSUInteger)bins
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    return [self gradientOrientationHistogramOfImageMatrix:image sobelKernelSize:ksize binCount:bins];
}

// from http://opencv-users.1802565.n2.nabble.com/Edge-orientation-td3146691.html

+ (NSArray<NSNumber *> *)gradientOrientationHistogramOfImageMatrix:(const cv::Mat &)image
                                                   sobelKernelSize:(NSUInteger)ksize
                                                          binCount:(NSUInteger)bins
{
    cv::Mat dx, dy;
    cv::Sobel(image, dx, CV_64F, 1, 0, (int)ksize);
    cv::Sobel(image, dy, CV_64F, 0, 1, (int)ksize);
    
    cv::Mat gradDir = cv::Mat(image.rows, image.cols, CV_32FC1);
    
    for (int i = 0; i < image.rows; i++) {
        for (int j = 0; j < image.cols; j++) {
            gradDir.at<float>(i, j) = atan2(dy.at<float>(i,j), dx.at<float>(i,j));
        }
    }
    
    int histSize[] = { (int)bins };
    
    float lranges[] = { -1.0, 1.0 };
    const float* ranges[] = {lranges};
    
    cv::Mat hist;
    int channels[] = { 0 };
    
    cv::calcHist(&gradDir, 1, channels, cv::Mat(), hist, 1, histSize, ranges, true, false);
    
    normalize(hist, hist, -1, 1, CV_MINMAX);
    
    NSMutableArray<NSNumber *> *histNumbers = [NSMutableArray new];
    for (int h = 0; h < bins; h++) {
        float f = hist.at<float>(h);
        [histNumbers addObject:@(MAX(0, f))];
    }
    
    return histNumbers;
}

MPMeanStandardDeviation MPMakeMeanStandardDeviation(float mu, float sigma) {
    MPMeanStandardDeviation musigma;
    musigma.mu = mu;
    musigma.sigma = sigma;
    return musigma;
}

- (MPMeanStandardDeviation)differenceOfImage:(CGImageRef)cgImage kernelSize:(NSUInteger)blurSize
{
    cv::Mat image = CVMatRepresentationGrayForCGImage(cgImage);
    return [self differenceOfImageMatrix:image kernelSize:blurSize];
}

- (MPMeanStandardDeviation)differenceOfImageMatrix:(const cv::Mat &)image kernelSize:(NSUInteger)blurSize
{
    cv::Mat blurredImage;
    cv::GaussianBlur(image, blurredImage, {(int)blurSize, (int)blurSize}, 0);
    
    cv::Mat differenceImage;
    cv::absdiff(image, blurredImage, differenceImage);
    
    cv::Scalar mu, sigma;
    cv::meanStdDev(differenceImage, mu, sigma);
    
    return MPMakeMeanStandardDeviation(mu.val[0], sigma.val[0]);
}

@end

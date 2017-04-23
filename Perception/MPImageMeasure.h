//
//  MPLaplacian.h
//  Perception
//
//  Created by Matias Piipari on 23/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    float mu;
    float sigma;
} MPMeanStandardDeviation;

MPMeanStandardDeviation MPMakeMeanStandardDeviation(float mu, float sigma);

// Objective-C method ports of http://stackoverflow.com/questions/7765810/is-there-a-way-to-detect-if-an-image-is-blurry
@interface MPImageMeasure : NSObject

+ (double)modifiedLaplacianOfImage:(nonnull CGImageRef)cgImage;
+ (double)laplacianVarianceOfImage:(nonnull CGImageRef)cgImage;
+ (double)tenengradScoreOfImage:(nonnull CGImageRef)cgImage kernelSize:(int)ksize;
+ (double)normalizedGraylevelVarianceOfImage:(nonnull CGImageRef)cgImage;
+ (double)cannyEdgePixelFractionOfImage:(nonnull CGImageRef)cgImage;

+ (nonnull NSArray<NSNumber *> *)gradientOrientationHistogramOfImage:(nonnull CGImageRef)cgImage
                                                     sobelKernelSize:(NSUInteger)ksize
                                                            binCount:(NSUInteger)bins;

- (MPMeanStandardDeviation)differenceOfImage:(nonnull CGImageRef)cgImage kernelSize:(NSUInteger)blurSize;

@end

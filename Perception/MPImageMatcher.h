//
//  Homography.h
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPFeatureDetector;

@interface MPImageMatcher : NSObject

@property (readonly) NSUInteger maxFeatureCount;

@property (readonly, nonnull) MPFeatureDetector *featureDetector;

- (nonnull instancetype)initWithSURFDetectorHessian:(double)hessian
                                matchIterationCount:(int)iterationCount;

- (double)medianMatchDistanceBetween:(nonnull CGImageRef)image
                            andImage:(nonnull CGImageRef)otherImage;

- (double)medianMatchDistanceBetween:(nonnull CGImageRef)image
                            andImage:(nonnull CGImageRef)otherImage
                  matchVisualization:(NSImage *_Nullable *_Nullable)matchVisualization;

@end

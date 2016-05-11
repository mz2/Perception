//
//  FeatureDetector.h
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, MPFeatureDetectorType) {
    MPFeatureDetectorTypeFAST       = 0,
    MPFeatureDetectorTypeSTAR       = 1,
    MPFeatureDetectorTypeSIFT       = 2,
    MPFeatureDetectorTypeSURF       = 3,
    MPFeatureDetectorTypeORB        = 4,
    MPFeatureDetectorTypeBRISK      = 5,
    MPFeatureDetectorTypeMSER       = 6,
    MPFeatureDetectorTypeGFTT       = 7,
    MPFeatureDetectorTypeHARRIS     = 8,
    MPFeatureDetectorTypeDense      = 9,
    MPFeatureDetectorTypeSimpleBlob = 10
};

@interface MPFeatureDetector : NSObject

@property (readonly) MPFeatureDetectorType detectorType;

@end

@interface MPFeatureDetectorSurf : MPFeatureDetector

@property (readwrite) double minThreshold;

- (instancetype)initWithThreshold:(double)minThreshold;
@end
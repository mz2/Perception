//
//  FeatureExtractor.h
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPFeatureExtractorType) {
    MPFeatureExtractorTypeSIFT  = 2,
    MPFeatureExtractorTypeSURF  = 3,
    MPFeatureExtractorTypeBRIEF = 100,
    MPFeatureExtractorTypeBRISK = 5,
    MPFeatureExtractorTypeORB   = 4,
    MPFeatureExtractorTypeFREAK = 101
};

@interface MPFeatureExtractor : NSObject
@property (readonly) MPFeatureExtractorType extractorType;
@end


@interface MPFeatureExtractorSurf : NSObject

@end
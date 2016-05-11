//
//  Homography.h
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPFeatureDetector;

@interface MPHomography : NSObject

@property (readonly) NSUInteger maxFeatureCount;

@property (readonly) MPFeatureDetector *featureDetector;

- (instancetype)initWithFeatureDetector:(MPFeatureDetector *)featureDetector;

- (void)homographyBetween:(NSImage *)image andImage:(NSImage *)otherImage;

@end

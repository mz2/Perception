//
//  FeatureDetector.m
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import "MPFeatureDetector.h"

@implementation MPFeatureDetector

@end


@implementation MPFeatureDetectorSurf

- (instancetype)initWithThreshold:(double)minThreshold {
    self = [super init];
    
    if (self) {
        self.minThreshold = minThreshold;
    }
    
    return self;
}

@end
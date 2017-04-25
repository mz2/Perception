//
//  NSArray+OpenCV.m
//  Perception
//
//  Created by Matias Piipari on 24/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

#import <opencv2/core.hpp>
#import "NSArray+OpenCV.h"

@implementation NSArray (OpenCV)

- (cv::Mat)matRepresentation {
    NSAssert(!self.firstObject || [self.firstObject isKindOfClass:NSArray.class],
             @"Expecting array of arrays with numbers, got as item: %@", self.firstObject);
    
    int pointCount = static_cast<int>(self.count);
    int columnCount = static_cast<int>([self.firstObject count]);
    cv::Mat data_pts(pointCount, columnCount, CV_64FC1);
    for (int r = 0; r < data_pts.rows; r++) {
        NSArray<NSNumber *> *point = self[r];
        for (int c = 0, cols = (int)point.count; c < cols; c++) {
            data_pts.at<double>(r, c) = point[c].doubleValue;
        }
    }
    return data_pts;
}

@end

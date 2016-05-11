//
//  MPMatchVisualizer.h
//  Perception
//
//  Created by Matias Piipari on 11/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <opencv2/core.hpp>
#import <vector>

#import <Foundation/Foundation.h>

@interface MPMatchVisualizer : NSObject

@property (readonly) int maxGoodMatchCount;
@property (readonly) double goodMatchPortion;

- (instancetype)initWithMaxGoodMatchCount:(int)maxGoodPointCount
                         goodMatchPortion:(double)goodMatchPortion;

- (cv::Mat)drawMatchesBetween:(const cv::Mat &)img1
                     andImage:(const cv::Mat&)img2
           comparingKeyPoints:(const std::vector<cv::KeyPoint>&)keypoints1
                  toKeyPoints:(const std::vector<cv::KeyPoint>&)keypoints2
                      matches:(std::vector<cv::DMatch>&)matches
                 sceneCorners:(std::vector<cv::Point2f>&)scene_corners_;

@end

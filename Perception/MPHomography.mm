//
//  Homography.m
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <opencv2/core.hpp>
#import <opencv2/features2d/features2d.hpp>
#import <opencv2/core.hpp>
#import <opencv2/xfeatures2d/nonfree.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/calib3d.hpp>
#import <opencv2/xfeatures2d.hpp>

#import <vector>
#import <iostream>

#import "SURFDetector.hpp"

#import <Cocoa/Cocoa.h>

#import "MPHomography.h"
#import "NSImage+OpenCV.h"
#import "MPMatchVisualizer.h"

using namespace cv;
using namespace cv::xfeatures2d;

// derived from the OpenCV3 SURF detector & extractor homography example.

@interface MPHomography ()
@property (readonly) MPMatchVisualizer *matchVisualizer;
@property (readonly) double SURFDetectorHessian;
@property (readonly) int iterationCount;
@end

@implementation MPHomography

+ (void)initialize {
    if (self == [MPHomography class]) {
        //cv::initModule_nonfree();
    }
}

- (instancetype)initWithSURFDetectorHessian:(double)hessian
                        matchIterationCount:(int)iterationCount {
    self = [super init];
    
    if (self) {
        _SURFDetectorHessian = hessian;
        _matchVisualizer = [[MPMatchVisualizer alloc] initWithMaxGoodMatchCount:50 goodMatchPortion:0.15f];
        _iterationCount = iterationCount;
    }
    
    return self;
}

- (void)homographyBetween:(NSImage *)image
                 andImage:(NSImage *)otherImage {
    [self homographyBetween:image andImage:otherImage matchVisualization:nil];
}

// adapted from http://docs.opencv.org/2.4/doc/tutorials/features2d/feature_homography/feature_homography.html

- (void)homographyBetween:(NSImage *)image
                 andImage:(NSImage *)otherImage
       matchVisualization:(NSImage **)matchVisualization

{
    
    cv::UMat img1 = [image UMatRepresentationGray];
    cv::UMat img2 = [otherImage UMatRepresentationGray];
    
    std::vector<cv::KeyPoint> keypoints_object, keypoints_scene;
    
    //declare input/output
    std::vector<KeyPoint> keypoints1, keypoints2;
    std::vector<DMatch> matches;
    
    UMat _descriptors1, _descriptors2;
    Mat descriptors1 = _descriptors1.getMat(ACCESS_RW),
    descriptors2 = _descriptors2.getMat(ACCESS_RW);
    
    //instantiate detectors/matchers
    SURFDetector surf;
    
    SURFMatcher<BFMatcher> matcher;
    
    //-- start of timing section
    
    for (int i = 0; i <= self.iterationCount; i++) {
        surf(img1.getMat(ACCESS_READ), Mat(), keypoints1, descriptors1);
        surf(img2.getMat(ACCESS_READ), Mat(), keypoints2, descriptors2);
        matcher.match(descriptors1, descriptors2, matches);
    }

    std::cout << "FOUND " << keypoints1.size() << " keypoints on first image" << std::endl;
    std::cout << "FOUND " << keypoints2.size() << " keypoints on second image" << std::endl;
    
    std::vector<Point2f> corner;
    
    if (matchVisualization) {
        NSImage *img = [NSImage imageFromMat:[self.matchVisualizer drawMatchesBetween:img1.getMat(ACCESS_READ)
                                                                             andImage:img2.getMat(ACCESS_READ)
                                                                   comparingKeyPoints:keypoints1
                                                                          toKeyPoints:keypoints2
                                                                              matches:matches
                                                                         sceneCorners:corner]];
        
        *matchVisualization = img;
    }
}

@end

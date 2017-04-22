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

#import "MPImageMatcher.h"
#import "NSImage+OpenCV.h"
#import "MPMatchVisualizer.h"

using namespace cv;
using namespace cv::xfeatures2d;

// derived from the OpenCV3 SURF detector & extractor homography example.

@interface MPImageMatcher ()
@property (readonly) MPMatchVisualizer *matchVisualizer;
@property (readonly) double SURFDetectorHessian;
@property (readonly) int iterationCount;
@end

@implementation MPImageMatcher

+ (void)initialize {
    if (self == [MPImageMatcher class]) {
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

- (double)medianMatchDistanceBetween:(CGImageRef)image andImage:(CGImageRef)otherImage {
    return [self medianMatchDistanceBetween:image andImage:otherImage matchVisualization:nil];
}

- (int)homographyScoreBetween:(const Mat &)img1
                     andImage:(const Mat&)img2
           comparingKeyPoints:(const std::vector<KeyPoint>&)keypoints1
                  toKeyPoints:(const std::vector<KeyPoint>&)keypoints2
                      matches:(std::vector<DMatch>&)matches
                 sceneCorners:(std::vector<Point2f>&)scene_corners_ {
    //-- Sort matches and preserve top 10% matches
    std::sort(matches.begin(), matches.end());
    std::vector< DMatch > good_matches;
    double minDist = matches.front().distance;
    double maxDist = matches.back().distance;
    
    const int ptsPairs = std::min(self.matchVisualizer.maxGoodMatchCount, (int)(matches.size() * self.matchVisualizer.goodMatchPortion));
    for( int i = 0; i < ptsPairs; i++ ) {
        good_matches.push_back( matches[i] );
    }
    std::cout << "\nMax distance: " << maxDist << std::endl;
    std::cout << "Min distance: " << minDist << std::endl;
    std::cout << "Calculating homography using " << ptsPairs << " point pairs." << std::endl;
    
    //-- Localize the object
    std::vector<Point2f> obj;
    std::vector<Point2f> scene;
    
    //-- Get the keypoints from the good matches
    for(size_t i = 0; i < good_matches.size(); i++) {
        obj.push_back( keypoints1[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints2[ good_matches[i].trainIdx ].pt );
    }
    
    Mat output;
    findHomography(obj, scene, output);
    
    // TODO: Whilst this appears to be useless at deciding.
    int score = 0;
    for (int i = 0; i < output.rows; i++) {
        for (int j = 0; j < output.cols; j++) {
            if (output.at<double>(j,i) > 0) {
                score++;
            }
        }
    }
    
    return score;
}

// adapted from http://docs.opencv.org/2.4/doc/tutorials/features2d/feature_homography/feature_homography.html

- (double)medianMatchDistanceBetween:(CGImageRef)image
                            andImage:(CGImageRef)otherImage
                  matchVisualization:(NSImage *__autoreleasing  _Nullable *)matchVisualization {
    NSParameterAssert(image);
    NSParameterAssert(otherImage);
    
    cv::Mat img1Mat = CVMatRepresentationGrayForCGImage(image);
    cv::Mat img2Mat = CVMatRepresentationGrayForCGImage(otherImage);
    cv::UMat img1 = img1Mat.getUMat(ACCESS_READ);
    cv::UMat img2 = img2Mat.getUMat(ACCESS_READ);
    
    //declare input/output
    std::vector<KeyPoint> keypoints1, keypoints2;
    std::vector<DMatch> matches;
    
    UMat _descriptors1, _descriptors2;
    Mat descriptors1 = _descriptors1.getMat(ACCESS_RW),
    descriptors2 = _descriptors2.getMat(ACCESS_RW);
    
    //instantiate detectors/matchers
    SURFDetector surf(self.SURFDetectorHessian);
    
    SURFMatcher<BFMatcher> matcher;
    
    //-- start of timing section
    
    NSParameterAssert(!img1Mat.empty());
    NSParameterAssert(!img2Mat.empty());
    
    NSParameterAssert(!img1.empty());
    NSParameterAssert(!img2.empty());
    
    for (int i = 0; i <= self.iterationCount; i++) {
        surf(img1.getMat(ACCESS_READ), Mat(), keypoints1, descriptors1);
        surf(img2.getMat(ACCESS_READ), Mat(), keypoints2, descriptors2);
        matcher.match(descriptors1, descriptors2, matches);
    }

    std::cout << "FOUND " << keypoints1.size() << " keypoints on first image" << std::endl;
    std::cout << "FOUND " << keypoints2.size() << " keypoints on second image" << std::endl;
    
    if (keypoints1.size() == 0 || keypoints2.size() == 0) {
        return 0;
    }
    
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
    
    //-- Sort matches and preserve top 10% matches
    std::sort(matches.begin(), matches.end());
    std::vector< DMatch > goodMatches;
    
    const int ptsPairs = std::min(self.matchVisualizer.maxGoodMatchCount, (int)(matches.size() * self.matchVisualizer.goodMatchPortion));
    for (int i = 0; i < ptsPairs; i++) {
        goodMatches.push_back( matches[i] );
    }
    
    std::vector<double> goodMatchValues;
    
    for (int i = 0; i < goodMatches.size(); i++) {
        goodMatchValues.push_back((double)matches.at(i).distance);
    }
    
    return vecMed(goodMatchValues);
}

double vecMed(std::vector<double> vec) {
    if(vec.empty()) return 0;
    else {
        std::sort(vec.begin(), vec.end());
        if(vec.size() % 2 == 0)
            return (vec[vec.size()/2 - 1] + vec[vec.size()/2]) / 2;
        else
            return vec[vec.size()/2];
    }
}

@end

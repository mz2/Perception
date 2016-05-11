//
//  MPMatchVisualizer.m
//  Perception
//
//  Created by Matias Piipari on 11/05/2016.
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

#import <Cocoa/Cocoa.h>

#import "MPMatchVisualizer.h"

using namespace cv;
using namespace cv::xfeatures2d;

@interface MPMatchVisualizer ()
@end

@implementation MPMatchVisualizer

- (instancetype)initWithMaxGoodMatchCount:(int)maxGoodPointCount
                         goodMatchPortion:(double)goodMatchPortion {
    self = [super init];
    
    if (self) {
        _maxGoodMatchCount = maxGoodPointCount;
        _goodMatchPortion = goodMatchPortion;
    }
    
    return self;
}

- (cv::Mat)drawMatchesBetween:(const Mat &)img1
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
    
    const int ptsPairs = std::min(self.maxGoodMatchCount, (int)(matches.size() * self.goodMatchPortion));
    for( int i = 0; i < ptsPairs; i++ )
    {
        good_matches.push_back( matches[i] );
    }
    std::cout << "\nMax distance: " << maxDist << std::endl;
    std::cout << "Min distance: " << minDist << std::endl;
    
    std::cout << "Calculating homography using " << ptsPairs << " point pairs." << std::endl;
    
    // drawing the results
    Mat img_matches;
    
    drawMatches(img1, keypoints1, img2, keypoints2,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
    
    //-- Localize the object
    std::vector<Point2f> obj;
    std::vector<Point2f> scene;
    
    for( size_t i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints1[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints2[ good_matches[i].trainIdx ].pt );
    }
    //-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<Point2f> obj_corners(4);
    obj_corners[0] = cv::Point(0,0);
    obj_corners[1] = cv::Point( img1.cols, 0 );
    obj_corners[2] = cv::Point( img1.cols, img1.rows );
    obj_corners[3] = cv::Point( 0, img1.rows );
    std::vector<Point2f> scene_corners(4);
    
    Mat H = findHomography(obj, scene, RANSAC);
    perspectiveTransform(obj_corners, scene_corners, H);
    
    scene_corners_ = scene_corners;
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    line(img_matches,
         scene_corners[0] + Point2f( (float)img1.cols, 0), scene_corners[1] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    line(img_matches,
         scene_corners[1] + Point2f( (float)img1.cols, 0), scene_corners[2] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    line(img_matches,
         scene_corners[2] + Point2f( (float)img1.cols, 0), scene_corners[3] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    line(img_matches,
         scene_corners[3] + Point2f( (float)img1.cols, 0), scene_corners[0] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    
    return img_matches;
}

@end

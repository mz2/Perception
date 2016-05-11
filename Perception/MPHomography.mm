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

#import <Cocoa/Cocoa.h>
#import "MPHomography.h"
#import "NSImage+OpenCV.h"
#import "MPFeatureDetector.h"


using namespace cv;
using namespace cv::xfeatures2d;

@implementation MPHomography

+ (void)initialize {
    if (self == [MPHomography class]) {
        //cv::initModule_nonfree();
    }
}

- (instancetype)initWithFeatureDetector:(MPFeatureDetector *)featureDetector {
    self = [super init];
    
    if (self) {
        _featureDetector = featureDetector;
    }
    
    return self;
}

struct SURFDetector
{
    Ptr<Feature2D> surf;
    SURFDetector(double hessian = 800.0)
    {
        surf = SURF::create(hessian);
    }
    template<class T>
    void operator()(const T& in, const T& mask, std::vector<cv::KeyPoint>& pts, T& descriptors, bool useProvided = false)
    {
        surf->detectAndCompute(in, mask, pts, descriptors, useProvided);
    }
};

template<class KPMatcher>
struct SURFMatcher
{
    KPMatcher matcher;
    template<class T>
    void match(const T& in1, const T& in2, std::vector<cv::DMatch>& matches)
    {
        matcher.match(in1, in2, matches);
    }
};


static Mat drawGoodMatches(
                           const Mat& img1,
                           const Mat& img2,
                           const std::vector<KeyPoint>& keypoints1,
                           const std::vector<KeyPoint>& keypoints2,
                           std::vector<DMatch>& matches,
                           std::vector<Point2f>& scene_corners_
                           )
{
    //-- Sort matches and preserve top 10% matches
    std::sort(matches.begin(), matches.end());
    std::vector< DMatch > good_matches;
    double minDist = matches.front().distance;
    double maxDist = matches.back().distance;
    
    const int ptsPairs = std::min(GOOD_PTS_MAX, (int)(matches.size() * GOOD_PORTION));
    for( int i = 0; i < ptsPairs; i++ )
    {
        good_matches.push_back( matches[i] );
    }
    std::cout << "\nMax distance: " << maxDist << std::endl;
    std::cout << "Min distance: " << minDist << std::endl;
    
    std::cout << "Calculating homography using " << ptsPairs << " point pairs." << std::endl;
    
    // drawing the results
    Mat img_matches;
    
    drawMatches( img1, keypoints1, img2, keypoints2,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS  );
    
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
    obj_corners[0] = Point(0,0);
    obj_corners[1] = Point( img1.cols, 0 );
    obj_corners[2] = Point( img1.cols, img1.rows );
    obj_corners[3] = Point( 0, img1.rows );
    std::vector<Point2f> scene_corners(4);
    
    Mat H = findHomography( obj, scene, RANSAC );
    perspectiveTransform( obj_corners, scene_corners, H);
    
    scene_corners_ = scene_corners;
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    line( img_matches,
         scene_corners[0] + Point2f( (float)img1.cols, 0), scene_corners[1] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    line( img_matches,
         scene_corners[1] + Point2f( (float)img1.cols, 0), scene_corners[2] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    line( img_matches,
         scene_corners[2] + Point2f( (float)img1.cols, 0), scene_corners[3] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    line( img_matches,
         scene_corners[3] + Point2f( (float)img1.cols, 0), scene_corners[0] + Point2f( (float)img1.cols, 0),
         Scalar( 0, 255, 0), 2, LINE_AA );
    return img_matches;
}

// adapted from http://docs.opencv.org/2.4/doc/tutorials/features2d/feature_homography/feature_homography.html

- (void)homographyBetween:(NSImage *)image
                 andImage:(NSImage *)otherImage
{
    cv::Mat img_object = [image cvMatRepresentationGray];
    cv::Mat img_scene = [otherImage cvMatRepresentationGray];
    
    if(!img_object.data || !img_scene.data) {
        std::cout<< " --(!) Error reading images " << std::endl;
        return;
    }
    
    //-- Step 1: Detect the keypoints using SURF Detector
    int minHessian = 400;
    
    std::vector<cv::KeyPoint> keypoints_object, keypoints_scene;
    
    detector.detect(img_object, keypoints_object);
    detector.detect(img_scene, keypoints_scene);
    
    //-- Step 2: Calculate descriptors (feature vectors)
    //cv::SurfDescriptorExtractor extractor;
    cv::BriefDescriptorExtractor extractor;
    
    cv::Mat descriptors_object, descriptors_scene;
    
    extractor.compute(img_object, keypoints_object, descriptors_object);
    extractor.compute(img_scene, keypoints_scene, descriptors_scene);
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    cv::FlannBasedMatcher matcher;
    std::vector<cv::DMatch> matches;
    matcher.match( descriptors_object, descriptors_scene, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_object.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector<cv::DMatch > good_matches;
    
    for( int i = 0; i < descriptors_object.rows; i++ )
    { if( matches[i].distance < 3*min_dist )
    { good_matches.push_back( matches[i]); }
    }
    
    cv::Mat img_matches;
    
    //cv::drawMatches( img_object, keypoints_object, img_scene, keypoints_scene,
    //            good_matches, img_matches, cv::Scalar::all(-1), cv::Scalar::all(-1),
    //            std::vector<char>(), cv::DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
    
    //-- Localize the object
    std::vector<cv::Point2f> obj;
    std::vector<cv::Point2f> scene;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
    }
     */
}

@end

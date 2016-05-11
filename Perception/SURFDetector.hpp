//
//  SURFDetector.hpp
//  Perception
//
//  Created by Matias Piipari on 11/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#ifndef SURFDetector_hpp
#define SURFDetector_hpp

#import <opencv2/core.hpp>
#import <opencv2/features2d/features2d.hpp>
#import <opencv2/core.hpp>
#import <opencv2/xfeatures2d/nonfree.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/calib3d.hpp>
#import <opencv2/xfeatures2d.hpp>

#import <Cocoa/Cocoa.h>

using namespace cv;
using namespace cv::xfeatures2d;

struct SURFDetector {
    Ptr<Feature2D> surf;
    SURFDetector(double hessian = 800.0) {
        surf = SURF::create(hessian);
    }
    template<class T>
    void operator()(const T& in, const T& mask, std::vector<cv::KeyPoint>& pts, T& descriptors, bool useProvided = false) {
        surf->detectAndCompute(in, mask, pts, descriptors, useProvided);
    }
};

template<class KPMatcher>
struct SURFMatcher {
    KPMatcher matcher;
    template<class T>
    void match(const T& in1, const T& in2, std::vector<cv::DMatch>& matches) {
        matcher.match(in1, in2, matches);
    }
};

#endif /* SURFDetector_hpp */

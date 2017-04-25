//
//  MPPrincipalComponentAnalysis.m
//  Perception
//
//  Created by Matias Piipari on 21/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

#include <opencv2/opencv.hpp>

#import "MPPrincipalComponentAnalysis.h"
#import "NSArray+OpenCV.h"

NSString *const MPPrincipalComponentAnalysisErrorDomain = @"MPPrincipalComponentAnalysisErrorDomain";

@interface MPPrincipalComponentAnalysis () {
    cv::PCA _pca;
}
@end

@implementation MPPrincipalComponentAnalysis

- (instancetype)initWithPrincipalComponents:(const cv::PCA &)pca projectedPoints:(NSArray<NSArray<NSNumber *> *> *)projectedPoints
{
    self = [super init];
    
    if (self) {
        _pca = pca;
        _projectedPoints = projectedPoints;
    }
    
    return self;
}

// NOTE! May throw a C++ exception (preferred to do it this way still because otherwise return type would need to be a pointer).
+ (cv::PCA)principalComponentsFromURL:(NSURL *)URL {
    cv::PCA pca = cv::PCA();
    cv::FileStorage fs = cv::FileStorage(URL.path.UTF8String, cv::FileStorage::READ);
    fs["mean"] >> pca.mean;
    fs["e_vectors"] >> pca.eigenvectors;
    fs["e_values"] >> pca.eigenvalues;
    fs.release();
    return pca;
}

- (BOOL)saveToURL:(NSURL *)URL error:(NSError **)error {
    // C++ exceptions are caught with @try these days too – MAGIC!
    @try {
        cv::FileStorage fs(URL.path.UTF8String, cv::FileStorage::WRITE);
        fs << "mean" << _pca.mean;
        fs << "e_vectors" << _pca.eigenvectors;
        fs << "e_values" << _pca.eigenvalues;
        fs.release();
    }
    @catch (...) {
        if (error) {
            *error = [NSError errorWithDomain:MPPrincipalComponentAnalysisErrorDomain
                                         code:MPPrincipalComponentAnalysisErrorCodeFailedToSerialize
                                     userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to save a principal component analysis to '%@'", URL.path],
                                                 NSLocalizedFailureReasonErrorKey: @"Please check that you have access to writing to '%@' and try again." }];
        }
        return NO;
    }
    return YES;
}


+ (cv::PCA)principalComponentsForPoints:(NSArray<NSArray<NSNumber *> *> *)points principalComponentCount:(NSUInteger)componentCount {
    cv::Mat data_pts = points.matRepresentation;
    cv::PCA pca_analysis(data_pts, cv::Mat(), CV_PCA_DATA_AS_ROW, (int)componentCount);
    return pca_analysis;
}

+ (MPPrincipalComponentAnalysis *)analyzePoints:(NSArray<NSArray<NSNumber *> *> *)points
                        withPrincipalComponents:(const cv::PCA &)pca_analysis {
    int pointCount = static_cast<int>(points.count);
    int componentCount = pca_analysis.eigenvectors.cols;
    
    cv::Mat data_pts = points.matRepresentation;
    cv::Mat projection = pca_analysis.project(data_pts);
    
    NSMutableArray *projections = [NSMutableArray new];
    for (int p = 0; p < pointCount; p++) {
        NSMutableArray *proj = [NSMutableArray new];
        for (int i = 0; i < componentCount; i++) {
            [proj addObject:@(projection.at<double>(p, i))];
        }
        [projections addObject:proj];
    }
    
    return [[MPPrincipalComponentAnalysis alloc] initWithPrincipalComponents:pca_analysis projectedPoints:projections];
}

+ (MPPrincipalComponentAnalysis *)analyzePoints:(NSArray<NSArray<NSNumber *> *> *)points principalComponentCount:(NSUInteger)componentCount {
    cv::PCA pca_analysis = [self principalComponentsForPoints:points principalComponentCount:componentCount];
    return [self analyzePoints:points withPrincipalComponents:pca_analysis];
}

+ (MPPrincipalComponentAnalysis *)analyzePoints:(NSArray<NSArray<NSNumber *> *> *)points withPrincipalComponentsFromURL:(NSURL *)URL error:(NSError **)error {
    @try {
        cv::PCA pca_analysis = [self principalComponentsFromURL:URL];
        return [self analyzePoints:points withPrincipalComponents:pca_analysis];
    }
    @catch (...) {
        if (error) {
            *error = [NSError errorWithDomain:MPPrincipalComponentAnalysisErrorDomain
                                         code:MPPrincipalComponentAnalysisErrorCodeFailedToDeserialize
                                     userInfo:@{ NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"Failed to load a principal component analysis from '%@'", URL.path],
                                                 NSLocalizedFailureReasonErrorKey:
                                                     @"Please check that you have access to reading from '%@' and that a serialized principal component analysis file exists there." }];
        }
        return nil;
    }
}

@end

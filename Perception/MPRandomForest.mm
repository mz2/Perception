//
//  MPRandomForest.m
//  Perception
//
//  Created by Matias Piipari on 24/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//


#include <opencv2/core.hpp>
#include <opencv2/ml.hpp>

#import "MPRandomForest.h"

#import "NSArray+OpenCV.h"

NSString *const MPRandomForestErrorDomain = @"MPRandomForestErrorDomain";

@interface MPRandomForest () {
    cv::Ptr<cv::ml::RTrees> _forest;
}

@end

@implementation MPClassificationReport

- (instancetype)initWithCorrectClassificationRate:(double)correctRate falsePositiveRates:(NSArray<NSNumber *> *)falsePositiveRates {
    self = [super init];
    
    if (self) {
        _correctClassificationRate = correctRate;
        _falsePositiveRates = falsePositiveRates;
    }
    
    return self;
}

- (double)incorrectClassificationRate {
    return 1.0 - _correctClassificationRate;
}

@end

@implementation MPRandomForest

- (instancetype)initWithTrees:(const cv::Ptr<cv::ml::RTrees> &)forest
{
    self = [super init];
    
    if (self) {
        self->_forest = forest;
    }
    
    return self;
}

- (void)dealloc {
    delete _forest;
}

+ (MPRandomForest *)randomForestFromFileURL:(NSURL *)fileURL error:(NSError **)error {
    auto trees = cv::ml::RTrees::create();
    
    trees->load(fileURL.path.UTF8String);
    return [[MPRandomForest alloc] initWithTrees:trees];
}

+ (MPRandomForest *)randomForestTrainedWithData:(NSArray<NSArray<NSNumber *> *> *)data classCount:(NSUInteger)numClasses {
    
    // define training data storage matrices (one for attribute examples, one
    // for classifications)
    
    const int numSamples = (int)data.count;
    const int numAttributes = (int)data.firstObject.count;
    
    cv::Mat training_data = cv::Mat(numSamples, numAttributes, CV_32FC1);
    cv::Mat training_classifications = cv::Mat(numSamples, 1, CV_32FC1);
    
    // define all the attributes as numerical
    // alternatives are CV_VAR_CATEGORICAL or CV_VAR_ORDERED(=CV_VAR_NUMERICAL)
    // that can be assigned on a per attribute basis
    
    cv::Mat var_type = cv::Mat(numAttributes + 1, 1, CV_8U);
    var_type.setTo(cv::Scalar(cv::ml::VAR_ORDERED)); // all inputs are numerical
    
    // this is a classification problem (i.e. predict a discrete number of class
    // outputs) so reset the last (+1) output var_type element to CV_VAR_CATEGORICAL
    
    var_type.at<uchar>(numAttributes, 0) = cv::ml::VAR_CATEGORICAL;
    
    // load training and testing data sets
    
    // define the parameters for training the random forest (trees)
    
    cv::Mat priorMatrix = cv::Mat(2, 1, CV_32FC1);
    priorMatrix.at<float>(0,0) = 0.5;
    priorMatrix.at<float>(1,0) = 0.5;
    
    // train random forest classifier (using training data)
    auto randomTrees = cv::ml::RTrees::create();
    
    randomTrees->setRegressionAccuracy(0);
    randomTrees->setMaxDepth(25);
    randomTrees->setMinSampleCount(5);
    randomTrees->setUseSurrogates(false); // no surrage splits = no missing data.
    randomTrees->setMaxCategories(15);
    randomTrees->setCalculateVarImportance(true);
    randomTrees->setPriors(priorMatrix);
    randomTrees->setTermCriteria(cv::TermCriteria(cv::TermCriteria::Type::COUNT, 10000, 0.001));
    //randomTrees->setActiveVarCount(4); sqrt(numAttributes) used by default when this is left to 0.
    //randomTrees->setCVFolds(10); // 10-fold CV I think is the default?
    
    randomTrees->train(training_data, cv::ml::ROW_SAMPLE, training_classifications);
    
    return [[MPRandomForest alloc] initWithTrees:randomTrees];
}

- (BOOL)saveToFileURL:(NSURL *)fileURL error:(NSError **)error {
    @try {
        _forest->save(fileURL.path.UTF8String);
    }
    @catch(...) {
        if (error) {
            *error = [NSError errorWithDomain:MPRandomForestErrorDomain
                                         code:MPRandomForestErrorCodeFailedToSaveModel
                                     userInfo:@{ NSLocalizedDescriptionKey: @"Failed to save model to file.",
                                                 NSLocalizedRecoverySuggestionErrorKey:
                                                     [NSString stringWithFormat:
                                                      @"Please ensure that you have write access to path '%@'", fileURL.path ]}];
        }
    }
    return YES;
}

- (MPClassificationReport *)testWithData:(NSArray<NSArray<NSNumber *> *> *)data classCount:(NSUInteger)numClasses {
    NSAssert(_forest != nil, @"Expecting the forest to have been trained.");
    
    const int numTestSamples = (int)data.count;
    const int numAttributes = (int)data.firstObject.count;
    
    cv::Mat testing_data = cv::Mat(numTestSamples, numAttributes, CV_32FC1);
    cv::Mat testing_classifications = cv::Mat(numTestSamples, 1, CV_32FC1);

    
    int correct_class = 0;
    int wrong_class = 0;
    
    cv::Mat false_positives = cv::Mat((int)numClasses, 1, CV_32S);
    for (int i = 0; i < numClasses; i++) {
        false_positives.at<int>(i, 0) = i;
    }
    
    for (int tsample = 0; tsample < numTestSamples; tsample++)
    {
        cv::Mat test_sample = testing_data.row(tsample);
        
        double result = _forest->predict(test_sample);
        
        // if the prediction and the (true) testing classification are the same
        // (N.B. openCV uses a floating point decision tree implementation!)
        if (fabs(result - testing_classifications.at<float>(tsample, 0)) >= FLT_EPSILON)
        {
            // if they differ more than floating point error => wrong class
            wrong_class++;
            false_positives.at<int>(result, 0)++;
        }
        else
        {
            correct_class++;
        }
    }
    
    NSMutableArray *falsePositives = [NSMutableArray new];
    for (int i = 0; i < numClasses; i++) {
        [falsePositives addObject:@(false_positives.at<double>(i, 0) / (double)numTestSamples)];
    }
    
    return [[MPClassificationReport alloc] initWithCorrectClassificationRate:(double)correct_class / (double)numTestSamples
                                                          falsePositiveRates:falsePositives];
}

- (NSInteger)predictedClassForSample:(NSArray<NSNumber *> *)sample {
    NSAssert(_forest != nil, @"Expecting the forest to have been trained.");
    cv::Mat sampleMatrix = [sample matRepresentation];
    return (NSUInteger)roundf(_forest->predict(sampleMatrix));
}

- (double)predictedNumericalValueForSample:(NSArray<NSNumber *> *)sample {
    NSAssert(_forest != nil, @"Expecting the forest to have been trained.");
    cv::Mat sampleMatrix = [sample matRepresentation];
    return _forest->predict(sampleMatrix);
}

@end

//
//  MPRandomForest.h
//  Perception
//
//  Created by Matias Piipari on 24/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *_Nonnull const MPRandomForestErrorDomain;

typedef NS_ENUM(NSUInteger, MPRandomForestErrorCode) {
    MPRandomForestErrorCodeFailedToSaveModel = 1
};

@interface MPClassificationReport: NSObject

@property (readonly) double correctClassificationRate;
@property (readonly) double incorrectClassificationRate;

/** Per class false positive rates. */
@property (readonly, nonnull) NSArray<NSNumber *> *falsePositiveRates;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end

@interface MPRandomForest : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;

+ (nullable MPRandomForest *)randomForestFromFileURL:(nonnull NSURL *)fileURL error:(NSError *_Nullable *_Nullable)error;

+ (nullable MPRandomForest *)randomForestTrainedWithData:(nonnull NSArray<NSArray<NSNumber *> *> *)data;

- (BOOL)saveToFileURL:(nonnull NSURL *)fileURL error:(NSError *_Nullable *_Nullable)error;

- (NSInteger)predictedClassForSample:(nonnull NSArray<NSNumber *> *)sample;

- (double)predictedNumericalValueForSample:(nonnull NSArray<NSNumber *> *)sample;

@end

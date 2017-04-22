//
//  MPPrincipalComponentAnalysis.h
//  Perception
//
//  Created by Matias Piipari on 21/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *_Nonnull const MPPrincipalComponentAnalysisErrorDomain;

typedef NS_ENUM(NSUInteger, MPPrincipalComponentAnalysisErrorCode) {
    MPPrincipalComponentAnalysisErrorCodeFailedToSerialize = 1,
    MPPrincipalComponentAnalysisErrorCodeFailedToDeserialize = 2
};

@interface MPPrincipalComponentAnalysis : NSObject

@property (readonly, nonnull) NSArray<NSArray<NSNumber *> *> *projectedPoints;

+ (nonnull MPPrincipalComponentAnalysis *)analyzePoints:(nonnull NSArray<NSArray<NSNumber *> *> *)points principalComponentCount:(NSUInteger)componentCount;

+ (nullable MPPrincipalComponentAnalysis *)analyzePoints:(nonnull NSArray<NSArray<NSNumber *> *> *)points
                          withPrincipalComponentsFromURL:(nonnull NSURL *)URL
                                                   error:(NSError *_Nullable *_Nullable)error;

- (BOOL)saveToURL:(nonnull NSURL *)URL error:(NSError *_Nullable * _Nullable)error;

@end

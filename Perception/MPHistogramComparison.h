//
//  MPHistogramComparison.h
//  Perception
//
//  Created by Matias Piipari on 12/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPHistogramOutputType) {
    MPHistogramOutputType1DBins = 0,
    MPHistogramOutputTypeHSBCoordinates = 1,
    MPHistogramOutputTypeHSBCoordinatesNormalized = 2
};

@interface MPHistogramComparison : NSObject

@property (readonly) int hueBinCount;
@property (readonly) int saturationBinCount;

+ (float)earthMoverDistanceBetween:(nonnull CGImageRef)image
                          andImage:(nonnull CGImageRef)otherImage
                       hueBinCount:(NSUInteger)hueBinCount
                saturationBinCount:(NSUInteger)saturationBinCount NS_SWIFT_NAME(earthMoverDistance(betweenImage:andImage:hueBinCount:saturationBinCount:));

+ (float)earthMoverDistanceBetweenHistogram:(nonnull NSArray<NSNumber *> *)histogramA
                               andHistogram:(nonnull NSArray<NSNumber *> *)histogramB
                                hueBinCount:(NSUInteger)hueBinCount
                         saturationBinCount:(NSUInteger)saturationBinCount NS_SWIFT_NAME(earthMoverDistance(betweenHistogram:andHistogram:hueBinCount:saturationBinCount:));

+ (nonnull NSArray<NSNumber *> *)HSBHistogramForImage:(nonnull CGImageRef)image
                                          hueBinCount:(NSUInteger)hueBinCount
                                   saturationBinCount:(NSUInteger)saturationBinCount
                                           outputType:(MPHistogramOutputType)outputType NS_SWIFT_NAME(hsbHistogram(image:hueBinCount:saturationBinCount:outputType:));

@end

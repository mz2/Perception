//
//  MPHistogramComparison.h
//  Perception
//
//  Created by Matias Piipari on 12/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPHistogramComparison : NSObject

@property (readonly) int hueBinCount;
@property (readonly) int saturationBinCount;

- (instancetype)initWithHueBinCount:(int)hueBinCount saturationBinCount:(int)saturationBinCount;

- (double)earthMoverDistanceBetween:(NSImage *)image andImage:(NSImage *)otherImage;

@end

//
//  NSArray+OpenCV.h
//  Perception
//
//  Created by Matias Piipari on 24/04/2017.
//  Copyright © 2017 Matias Piipari & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (OpenCV)

/** Should be called only on a NSArray<NSArray<NSNumber *> *> * */
- (cv::Mat)matRepresentation;

@end

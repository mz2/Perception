//
//  NSImage+OpenCV.h
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <Cocoa/Cocoa.h>

// adapted from https://github.com/objcio/issue-21-OpenCV-FaceRec/blob/master/FaceRec/UIImage%2BOpenCV.h

@interface NSImage (OpenCV)

+ (NSImage *)imageFromMat:(cv::Mat)cvMat;

@end

cv::Mat CVMatRepresentationColorForCGImage(CGImageRef imageRef);
cv::Mat CVMatRepresentationGrayForCGImage(CGImageRef imageRef);

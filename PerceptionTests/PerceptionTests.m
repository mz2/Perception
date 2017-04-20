//
//  PerceptionTests.m
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <XCTest/XCTest.h>

@import Perception;

@interface PerceptionTests : XCTestCase

@end

@implementation PerceptionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMedianMatchDistanceMeasure {
    MPImageMatcher *imageMatcher = [[MPImageMatcher alloc] initWithSURFDetectorHessian:400 matchIterationCount:10];
    
    NSImage *imageA = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-A.png"];
    NSImage *imageB = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-B.png"];
    NSImage *imageC = [[NSBundle bundleForClass:self.class] imageForResource:@"treebark.png"];
    
    CGImageRef imgA = [imageA CGImageForProposedRect:nil context:nil hints:nil];
    CGImageRef imgB = [imageB CGImageForProposedRect:nil context:nil hints:nil];
    CGImageRef imgC = [imageC CGImageForProposedRect:nil context:nil hints:nil];
    
    double scoreAB = [imageMatcher medianMatchDistanceBetween:imgA andImage:imgB];
    double scoreAC = [imageMatcher medianMatchDistanceBetween:imgA andImage:imgC];
    double scoreBC = [imageMatcher medianMatchDistanceBetween:imgB andImage:imgC];
    
    XCTAssert(scoreAB < scoreAC);
    XCTAssert(scoreAB < scoreBC);
    
    imageA = nil;
    imageB = nil;
    imageC = nil;
}

- (void)testEarthMoverDistanceMeasure {
    NSImage *imageA = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-A.png"];
    NSImage *imageB = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-B.png"];
    NSImage *imageC = [[NSBundle bundleForClass:self.class] imageForResource:@"treebark.png"];
    
    CGImageRef imgA = [imageA CGImageForProposedRect:nil context:nil hints:nil];
    CGImageRef imgB = [imageB CGImageForProposedRect:nil context:nil hints:nil];
    CGImageRef imgC = [imageC CGImageForProposedRect:nil context:nil hints:nil];
    
    float scoreAB = [MPHistogramComparison earthMoverDistanceBetween:imgA andImage:imgB hueBinCount:32 saturationBinCount:32];
    float scoreAC = [MPHistogramComparison earthMoverDistanceBetween:imgA andImage:imgC hueBinCount:32 saturationBinCount:32];
    float scoreBC = [MPHistogramComparison earthMoverDistanceBetween:imgB andImage:imgC hueBinCount:32 saturationBinCount:32];
    
    XCTAssert(scoreAB < scoreAC);
    XCTAssert(scoreAB < scoreBC);
    
    imageA = nil;
    imageB = nil;
    imageC = nil;
}

@end

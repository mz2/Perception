//
//  PerceptionTests.m
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Perception/Perception.h>

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
    
    NSImage *imgA = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-A.png"];
    NSImage *imgB = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-B.png"];
    NSImage *imgC = [[NSBundle bundleForClass:self.class] imageForResource:@"treebark.png"];
    
    double scoreAB = [imageMatcher medianMatchDistanceBetween:imgA andImage:imgB];
    double scoreAC = [imageMatcher medianMatchDistanceBetween:imgA andImage:imgC];
    double scoreBC = [imageMatcher medianMatchDistanceBetween:imgB andImage:imgC];
    
    XCTAssert(scoreAB < scoreAC);
    XCTAssert(scoreAB < scoreBC);
}

- (void)testEarthMoverDistanceMeasure {
    MPHistogramComparison *comparison = [[MPHistogramComparison alloc] initWithHueBinCount:30 saturationBinCount:32];
    
    NSImage *imgA = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-A.png"];
    NSImage *imgB = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-B.png"];
    NSImage *imgC = [[NSBundle bundleForClass:self.class] imageForResource:@"treebark.png"];
    
    double scoreAB = [comparison earthMoverDistanceBetween:imgA andImage:imgB];
    double scoreAC = [comparison earthMoverDistanceBetween:imgA andImage:imgC];
    double scoreBC = [comparison earthMoverDistanceBetween:imgB andImage:imgC];
    
    XCTAssert(scoreAB < scoreAC);
    XCTAssert(scoreAB < scoreBC);
}

@end

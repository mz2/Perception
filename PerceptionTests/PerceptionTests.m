//
//  PerceptionTests.m
//  Perception
//
//  Created by Matias Piipari on 10/05/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPHomography.h"

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

- (void)testHomography {
    MPHomography *homography = [[MPHomography alloc] initWithSURFDetectorHessian:400 matchIterationCount:10];
    
    NSImage *imgA = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-A.png"];
    NSImage *imgB = [[NSBundle bundleForClass:self.class] imageForResource:@"kool-thing-B.png"];
    NSImage *imgC = [[NSBundle bundleForClass:self.class] imageForResource:@"treebark.png"];
    
    int scoreAB = [homography homographyScoreBetween:imgA andImage:imgB];
    int scoreAC = [homography homographyScoreBetween:imgA andImage:imgC];
    int scoreBC = [homography homographyScoreBetween:imgB andImage:imgC];
    
    XCTAssert(scoreAB > scoreAC);
    XCTAssert(scoreAB > scoreBC);
    
}

@end

//
//  friendsforredditTests.m
//  friendsforredditTests
//
//  Created by Gregory Johnson on 4/5/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RedditAPI.h"

@interface friendsforredditTests : XCTestCase
@property RedditAPI *api;
@end

@implementation friendsforredditTests

@synthesize api;

- (void)setUp {
    [super setUp];
    api = [RedditAPI sharedRedditAPI];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

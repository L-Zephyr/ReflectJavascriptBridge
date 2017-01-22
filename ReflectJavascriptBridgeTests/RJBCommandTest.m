//
//  RJBCommandTest.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RJBCommand.h"
#import "BridgeClass.h"

@interface RJBCommandTest : XCTestCase

@end

@implementation RJBCommandTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

- (void)testCommand {
    BridgeClass *obj = [[BridgeClass alloc] init];
    NSDictionary *info = @{@"className": @"BridgeClass",
                           @"identifier": @"1",
                           @"method": @"function",
                           @"args": @[]};
    RJBCommand *command = [RJBCommand commandWithDic:info];
    [command exec:obj];
}

@end

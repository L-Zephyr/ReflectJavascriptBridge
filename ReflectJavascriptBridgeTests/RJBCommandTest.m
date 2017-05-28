//
//  RJBCommandTest.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/4/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReflectJavascriptBridge.h"
#import "RJBCommand.h"

// bridge class

@protocol ExportProtocol<ReflectBridgeExport>

JSExportAs(add, - (NSInteger)add:(NSInteger)a b:(NSInteger)b);

@end

@interface BridgeClass: NSObject<ExportProtocol>

@end

@implementation BridgeClass

- (NSInteger)add:(NSInteger)a b:(NSInteger)b {
    return a + b;
}

@end

// test class
@interface RJBCommandTest : XCTestCase

@property (nonatomic) NSMutableDictionary *info;

@end

@implementation RJBCommandTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _info = [@{@"className" : @"BridgeClass"} mutableCopy];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _info = [@{} mutableCopy];
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

- (void)testCommandWithInt {
    _info[@"identifier"] = @"obj";
    _info[@"args"] = @[@1, @2];
    _info[@"method"] = @"add:b";
    _info[@"callbackId"] = @0;
    _info[@"returnType"] = @"q";
    
    BridgeClass *obj = [[BridgeClass alloc] init];
    RJBCommand *command = [RJBCommand commandWithDic:[_info copy]];
}

- (void)testCommandWithFloat {
    
}

- (void)testCommandWithString {
    
}

@end

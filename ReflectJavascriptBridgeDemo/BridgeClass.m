//
//  BridgeClass.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "BridgeClass.h"

@implementation BridgeClass

+ (void)classFunction {
    NSLog(@"call class function");
}

- (void)function {
    NSLog(@"call function");
}

- (NSInteger)add:(NSInteger)a b:(NSInteger)b {
    NSLog(@"%ld add %ld = %ld", a, b, a + b);
    return a+b;
}

@end

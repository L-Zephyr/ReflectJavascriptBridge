//
//  BridgeClass.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "BridgeClass.h"

@implementation BridgeClass

- (void)function {
    NSLog(@"call function");
}

- (void)add:(NSInteger)a b:(NSInteger)b {
    NSLog(@"%ld add %ld = %ld", a, b, a + b);
}

@end

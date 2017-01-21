//
//  OCClass.m
//  Reflect
//
//  Created by LZephyr on 2017/1/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "OCClass.h"

@implementation OCClass

- (instancetype)init {
    self = [super init];
    if (self) {
        ReflectJavascriptBridge *bridge = [[ReflectJavascriptBridge alloc] init];
        bridge[@"name"] = @"wind";
    }
    return self;
}

@end

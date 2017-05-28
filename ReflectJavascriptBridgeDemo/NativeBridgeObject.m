//
//  NativeBridgeObject.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/5/28.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "NativeBridgeObject.h"

@implementation NativeBridgeObject

- (void)sample1 {
    NSLog(@"JS调用native.sample1");
}

- (void)sample2:(NSString *)param {
    NSLog(@"JS调用native.sample2, 参数: %@", param);
}

- (NSString *)sample3 {
    NSLog(@"JS调用native.sample3, 返回'native param'");
    return @"native param";
}

- (NSString *)sample4:(NSString *)str1 str:(NSString *)str2 {
    NSLog(@"JS调用native.sample4");
    return [str1 stringByAppendingString:str2];
}

- (NSString *)sample5:(NSInteger)a b:(float)b c:(double)c {
    NSLog(@"JS调用native.sample5");
    return [NSString stringWithFormat:@"%ld+%.2f+%.2f is %.2f", a, b, c, a + b + c];
}

- (NSString *)sample6:(NSArray *)array dic:(NSDictionary *)dic {
    NSLog(@"JS调用native.sample6, 参数: array: %@\ndic: %@", array, dic);
    return [NSString stringWithFormat:@"array.len = %ld, dic.len = %ld", array.count, dic.count];
}

- (NSString *)sample7:(RJBCallback)callback {
    NSLog(@"JS调用native.sample7, 执行闭包");
    callback(@[@"callback param"]);
    return @"return value";
}

@end

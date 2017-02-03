//
//  BridgeClass.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "BridgeClass.h"

@implementation BridgeClass

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"call from js"
                                                   delegate:nil
                                          cancelButtonTitle:@"cancel"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (NSInteger)add:(NSInteger)a b:(NSInteger)b {
    NSLog(@"%ld add %ld = %ld", a, b, a + b);
    return a+b;
}

- (void)setName:(NSString *)name {
    _name = name;
    NSLog(@"js change property value to %@", name);
}

@end

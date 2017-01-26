//
//  BridgeClass.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReflectJavascriptBridge.h"

@protocol BridgeProtocol <ReflectBridgeExport>

@property (nonatomic) NSString *name;
@property (nonatomic) BOOL success;
@property (nonatomic) NSInteger age;

+ (void)classFunction;

- (void)function;

- (NSInteger)add:(NSInteger)a b:(NSInteger)b;

@end

@interface BridgeClass : NSObject <BridgeProtocol>

@property (nonatomic) NSString *name;
@property (nonatomic) BOOL success;
@property (nonatomic) NSInteger age;

+ (void)classFunction;

- (void)function;

- (NSInteger)add:(NSInteger)a b:(NSInteger)b;

@end

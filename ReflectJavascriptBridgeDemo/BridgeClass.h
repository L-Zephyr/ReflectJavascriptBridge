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

+ (void)classFunction;

- (void)function;

- (void)add:(NSInteger)a b:(NSInteger)b;

@end

@interface BridgeClass : NSObject <BridgeProtocol>

+ (void)classFunction;

- (void)function;

- (void)add:(NSInteger)a b:(NSInteger)b;

@end

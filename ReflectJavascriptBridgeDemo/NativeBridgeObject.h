//
//  NativeBridgeObject.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/5/28.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReflectJavascriptBridge.h"

@protocol NativeExported <ReflectBridgeExport>

- (void)sample1;
- (void)sample2:(NSString *)param;
- (NSString *)sample3;
JSExportAs(sample4, - (NSString *)sample4:(NSString *)str1 str:(NSString *)str2);
JSExportAs(sample5, - (NSString *)sample5:(NSInteger)a b:(float)b c:(double)c);
JSExportAs(sample6, - (NSString *)sample6:(NSArray *)array dic:(NSDictionary *)dic);
JSExportAs(sample7, - (NSString *)sample7:(RJBCallback)callback);

@end

@interface NativeBridgeObject : NSObject <NativeExported>

@end

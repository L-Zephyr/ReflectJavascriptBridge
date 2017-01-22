//
//  RJBObjectConvertor.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReflectBridgeExport.h"

@interface RJBObjectConvertor : NSObject

/**
 将native实例转换成js对象的描述

 @param object   native对象实例
 @param moduleId 唯一的对象ID
 @return         描述一个JS对象的JS代码
 */
+ (NSString *)convertToJs:(id<ReflectBridgeExport>)object moduleId:(NSUInteger)moduleId;

@end

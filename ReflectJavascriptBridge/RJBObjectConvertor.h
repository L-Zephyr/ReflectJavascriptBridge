//
//  RJBObjectConvertor.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJBCommons.h"

@interface RJBObjectConvertor : NSObject

/**
 将native实例转换成js对象的描述

 @param object     native对象实例
 @param identifier 实例对象的名称
 @return           描述一个JS对象的JS代码
 */
+ (NSString *)convertToJs:(id)object identifier:(NSString *)identifier;

@end

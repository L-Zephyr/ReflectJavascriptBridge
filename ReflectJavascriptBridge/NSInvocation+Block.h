//
//  NSInvocation+Block.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/3/14.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Block)

/**
 创建一个NSInvocation来执行Block

 @param block invocation调用的block
 @return NSInvocation实例
 */
+ (instancetype)invocationWithBlock:(id)block;

/**
 创建一个NSInvocation来执行Block，并指定参数

 @param block invocation调用的block及其参数
 @return NSInvocation实例
 */
+ (instancetype)invocationWithBlockAndArgs:(id)block ,... NS_REQUIRES_NIL_TERMINATION;

/**
 创建一个NSInvocation来执行Block，并指定参数

 @param block invocation调用的block
 @param args 参数数组
 @return NSInvocation实例
 */
+ (instancetype)invocationWithBlock:(id)block argumentArray:(NSArray *)args;

@end

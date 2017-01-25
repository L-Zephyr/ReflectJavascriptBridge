//
//  ReflectJavascriptBridge.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RJBCommons.h"

@interface ReflectJavascriptBridge : NSObject

/**
 初始化ReflectJavascriptBridge对象

 @param webView  bridge的目标webView
 @param delegate webView的delegate对象
 @return         返回创建的的ReflectJavascriptBridge实例
 */
+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate;

/**
 初始化ReflectJavascriptBridge对象

 @param webView bridge的目标webView
 @return        返回创建的的ReflectJavascriptBridge实例
 */
+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView;

/**
 执行JS代码并返回执行结果

 @param js JS代码
 @return   JS执行结果
 */
- (NSString *)callJs:(NSString *)js;

// Subscript
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id<ReflectBridgeExport>)object forKeyedSubscript:(id<NSCopying>)aKey;

@end

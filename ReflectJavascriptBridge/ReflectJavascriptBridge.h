//
//  ReflectJavascriptBridge.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReflectBridgeExport.h"

@interface ReflectJavascriptBridge : NSObject

+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate;

+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;

@end
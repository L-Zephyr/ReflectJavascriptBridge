//
//  RJBWKWebViewBridge.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/2/3.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "ReflectJavascriptBridge.h"

@interface RJBWKWebViewBridge : ReflectJavascriptBridge

- (instancetype)initWithWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate>)delegate;

@end

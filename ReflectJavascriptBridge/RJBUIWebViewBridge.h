//
//  RJBUIWebViewBridge.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/2/3.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReflectJavascriptBridge.h"

@interface RJBUIWebViewBridge : ReflectJavascriptBridge

- (instancetype)initWithWebView:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate;

@end

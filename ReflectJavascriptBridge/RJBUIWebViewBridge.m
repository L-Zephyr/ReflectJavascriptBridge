//
//  RJBUIWebViewBridge.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/2/3.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBUIWebViewBridge.h"
#import "RJBCommand.h"
#import <objc/runtime.h>

// inherit from super class
@interface RJBUIWebViewBridge(protected)

@property (nonatomic) BOOL injectJsFinished;

- (void)injectJs;
- (void)execCommands;
- (void)fetchQueueingCommands;
- (NSString *)convertNativeObjectToJs:(id<ReflectBridgeExport>)object identifier:(NSString *)identifier;
- (void)bridgeObjectToJs:(id<ReflectBridgeExport>)obj name:(NSString *)name;

@end

@interface RJBUIWebViewBridge() <UIWebViewDelegate>

@property (nonatomic) id<UIWebViewDelegate> delegate;
@property (nonatomic) UIWebView *webView;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation RJBUIWebViewBridge

- (instancetype)initWithWebView:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _webView = webView;
        _delegate = delegate;
        _webView.delegate = self;
    }
    return self;
}

#pragma mark - Subclass implement method

- (void)callJs:(NSString *)js completionHandler:(void (^)(id, NSError *))handler {
    NSString *result = [_webView stringByEvaluatingJavaScriptFromString:js];
    if (handler != nil) {
        handler(result, nil);
    }
}

- (void)callJsMethod:(NSString *)methodName withArgs:(NSArray *)args completionHandler:(void (^)(id, NSError *))handler {
    if (!self.injectJsFinished) {
        NSLog(@"[RJB]: javascript initialize not complete!");
        if (handler != nil) {
            handler(nil, [NSError errorWithDomain:@"javascript initialize not complete!" code:0 userInfo:nil]);
        }
    }
    
    NSMutableString *paramStr = [NSMutableString string];
    for (id param in args) {
        if ([param isKindOfClass:[NSString class]]) {
            [paramStr appendFormat:@"\"%@\",", (NSString *)param];
        } else if ([param isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)param;
            [paramStr appendFormat:@"%@,", number];
        }
    }
    
    NSString *js = nil;
    if (paramStr.length > 0) {
        NSString *param = [paramStr substringToIndex:paramStr.length - 1]; // delete the last comma
        js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.checkAndCall(\"%@\",[%@]);", methodName, param];
    } else {
        js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.checkAndCall(\"%@\");", methodName];
    }
    
    NSString *result = [_webView stringByEvaluatingJavaScriptFromString:js];
    if (handler != nil) {
        handler(result, nil);
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([_delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([_delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_delegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:RJBScheme]) {
        if ([request.URL.host isEqualToString:RJBInjectJs]) {
            [self injectJs];
        } else if ([request.URL.host isEqualToString:RJBReadyForMessage]) {
            [self fetchQueueingCommands];
        }
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

@end

#pragma clang diagnostic pop

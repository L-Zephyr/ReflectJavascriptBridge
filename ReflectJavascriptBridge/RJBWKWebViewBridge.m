//
//  RJBWKWebViewBridge.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/2/3.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBWKWebViewBridge.h"
#import "ReflectJavascriptBridge.h"

// inherit from super class
@interface RJBWKWebViewBridge(protected)

@property (nonatomic) BOOL injectJsFinished;

- (void)injectJs;
- (void)execCommands;
- (void)fetchQueueingCommands;
- (NSString *)convertNativeObjectToJs:(id<ReflectBridgeExport>)object identifier:(NSString *)identifier;
- (void)bridgeObjectToJs:(id<ReflectBridgeExport>)obj name:(NSString *)name;

@end

@interface RJBWKWebViewBridge() <WKNavigationDelegate>

@property (nonatomic) id<WKNavigationDelegate> delegate;
@property (nonatomic) WKWebView *webView;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation RJBWKWebViewBridge

- (instancetype)initWithWebView:(WKWebView *)webView delegate:(id<WKNavigationDelegate>)delegate {
    self = [super init];
    if (self) {
        _webView = webView;
        _delegate = delegate;
        _webView.navigationDelegate = self;
    }
    return self;
}

#pragma mark - Subclass implement methods

- (void)callJs:(NSString *)js completionHandler:(void (^)(id, NSError *))handler {
    [_webView evaluateJavaScript:js completionHandler:handler];
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

    [_webView evaluateJavaScript:js completionHandler:handler];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.scheme isEqualToString:RJBScheme]) {
        if ([navigationAction.request.URL.host isEqualToString:RJBInjectJs]) {
            [self injectJs];
        } else if ([navigationAction.request.URL.host isEqualToString:RJBReadyForMessage]) {
            [self fetchQueueingCommands];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    if ([_delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end

#pragma clang diagnostic pop

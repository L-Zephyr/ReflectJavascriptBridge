//
//  ReflectJavascriptBridge.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "ReflectJavascriptBridge.h"
#import "ReflectBridgeExport.h"
#import "RJBObjectConvertor.h"
#import "RJBCommand.h"

static NSString *const ReflectScheme = @"ReflectJavascriptBridge";
static NSString *const ReflectReadyForMessage = @"_ReadyForCommands_";
static NSString *const ReflectInjectJs = @"";

@interface ReflectJavascriptBridge()<UIWebViewDelegate>

@property (nonatomic) NSMutableDictionary<NSString *, id<ReflectBridgeExport>> *reflectObjects;
@property (nonatomic) NSMutableArray<RJBCommand *> *commands;
@property (nonatomic) NSUInteger uniqueModuleId;
@property (nonatomic) id<UIWebViewDelegate> delegate;
@property (nonatomic) UIWebView *webView;

@end

@implementation ReflectJavascriptBridge

+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate {
    ReflectJavascriptBridge *bridge = [[ReflectJavascriptBridge alloc] initWithWebView:webView delegate:delegate];
    return bridge;
}

+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView {
    return [ReflectJavascriptBridge bridge:webView delegate:nil];
}

/**
 向JS中注册一个Native对象

 @param obj  native的对象实例
 @param name 实例名称
 */
- (void)bridgeObjectToJs:(id<ReflectBridgeExport>)obj name:(NSString *)name {
    NSString *jsObj = [self convertNativeObjectToJs:obj];
    NSString *js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.addObject(%@,%@);", jsObj, name];
    [_webView stringByEvaluatingJavaScriptFromString:js];
}

/**
 将一个native对象转换成JS对象的表示

 @param object native对象实例
 @return       一段描述JS对象的JS代码
 */
- (NSString *)convertNativeObjectToJs:(id<ReflectBridgeExport>)object {
    NSString *jsObject = [RJBObjectConvertor convertToJs:object moduleId:_uniqueModuleId];
    ++_uniqueModuleId;
    return jsObject;
}

/**
 从JS中获取待执行的command对象
 */
- (void)fetchQueueingCommands {
    NSString *json = [_webView stringByEvaluatingJavaScriptFromString:@"window.ReflectJavascriptBridge.dequeueCommandQueue();"];
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *commandArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (commandArray != nil) {
        for (NSDictionary *commandInfo in commandArray) {
            RJBCommand *command = [RJBCommand commandWithDic:commandInfo];
            if (command != nil) {
                [_commands addObject:command];
            }
        }
    }
    
    [self execCommands];
}

/**
 执行所有队列中的command
 */
- (void)execCommands {
    if (_commands.count == 0) {
        return;
    }
    
    for (RJBCommand *command in _commands) {
        [command exec:_reflectObjects[command.identifier]];
    }
    // TODO: 执行结束清空commands
}

- (instancetype)initWithWebView:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _webView = webView;
        _delegate = delegate;
        _webView.delegate = self;
    }
    return self;
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
    if ([request.URL.scheme isEqualToString:ReflectScheme]) {
        if ([request.URL.host isEqualToString:ReflectInjectJs]) {
            // TODO:注入JS代码
        } else if ([request.URL.host isEqualToString:ReflectReadyForMessage]) {
            [self fetchQueueingCommands];
        }
        return NO;
    }
    return YES;
}

@end

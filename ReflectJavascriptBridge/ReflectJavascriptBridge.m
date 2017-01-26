//
//  ReflectJavascriptBridge.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "ReflectJavascriptBridge.h"
#import "RJBCommons.h"
#import "RJBObjectConvertor.h"
#import "RJBCommand.h"
#import <objc/runtime.h>

static NSString *const ReflectScheme = @"reflectjavascriptbridge";
static NSString *const ReflectReadyForMessage = @"_ReadyForCommands_";
static NSString *const ReflectInjectJs = @"_InjectJs_";

@interface ReflectJavascriptBridge() <UIWebViewDelegate>

@property (nonatomic) NSMutableDictionary<NSString *, id<ReflectBridgeExport>> *reflectObjects;
@property (nonatomic) NSMutableDictionary<NSString *, id<ReflectBridgeExport>> *waitingObjects; // wait for bridge
@property (nonatomic) NSMutableArray<RJBCommand *> *commands;
@property (nonatomic) id<UIWebViewDelegate> delegate;
@property (nonatomic) UIWebView *webView;
@property (nonatomic) BOOL injectJsFinished;

@end

@implementation ReflectJavascriptBridge

+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate {
    ReflectJavascriptBridge *bridge = [[ReflectJavascriptBridge alloc] initWithWebView:webView delegate:delegate];
    return bridge;
}

+ (ReflectJavascriptBridge *)bridge:(UIWebView *)webView {
    return [ReflectJavascriptBridge bridge:webView delegate:nil];
}

- (NSString *)callJs:(NSString *)js {
    return [_webView stringByEvaluatingJavaScriptFromString:js];
}

- (NSString *)callMethod:(NSString *)methodName withArgs:(NSArray *)args {
    if (!_injectJsFinished) {
        NSLog(@"javascript initialize not complete!");
        return nil;
    }
    
    NSMutableString *paramStr = [NSMutableString string];
    for (id param in args) {
        if ([param isKindOfClass:[NSString class]]) {
            [paramStr appendFormat:@"\"%@\",", (NSString *)param];
        } else if ([param isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber *)param;
            const char *type = [number objCType];
            if (strcmp(type, @encode(double)) == 0) {
                [paramStr appendFormat:@"%g,", [number doubleValue]];
            } else if (strcmp(type, @encode(BOOL)) == 0) {
                [paramStr appendFormat:@"%@,", [number boolValue] ? @"true" : @"false"];
            } else {
                [paramStr appendFormat:@"%ld,", [number integerValue]];
            }
        }
    }
    
    NSString *js = nil;
    if (paramStr.length > 0) {
        NSString *param = [paramStr substringToIndex:paramStr.length - 1]; // TODO: 去掉最后一个逗号
        js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.checkAndCall(\"%@\",[%@]);", methodName, param];
    } else {
        js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.checkAndCall(\"%@\");", methodName];
    }
    
    
    return [_webView stringByEvaluatingJavaScriptFromString:js];
}

/**
 向JS中注册一个Native对象

 @param obj  native的对象实例
 @param name 实例名称
 */
- (void)bridgeObjectToJs:(id<ReflectBridgeExport>)obj name:(NSString *)name {
    NSString *jsObj = [self convertNativeObjectToJs:obj identifier:name];
    NSString *js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.addObject(%@,\"%@\");", jsObj, name];
    [self callJs:js];
}

/**
 将一个native对象转换成JS对象的表示

 @param object native对象实例
 @return       一段描述JS对象的JS代码
 */
- (NSString *)convertNativeObjectToJs:(id<ReflectBridgeExport>)object identifier:(NSString *)identifier {
    NSString *jsObject = [RJBObjectConvertor convertToJs:object identifier:identifier];
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
        [command execWithInstance:_reflectObjects[command.identifier] bridge:self];
    }
    // TODO: 执行结束清空commands, 暂时先同步执行
    [_commands removeAllObjects];
}

/**
 向webView中注入JS代码
 */
- (void)injectJs {
    NSString *result = [_webView stringByEvaluatingJavaScriptFromString:ReflectJavascriptBridgeInjectedJS()];
    _injectJsFinished = YES;
    [_waitingObjects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<ReflectBridgeExport>  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setObject:obj forKeyedSubscript:key];
    }];
    [_waitingObjects removeAllObjects];
}

#pragma mark - Initialize

- (instancetype)initWithWebView:(UIWebView *)webView delegate:(id<UIWebViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _webView = webView;
        _delegate = delegate;
        _webView.delegate = self;
        _reflectObjects = [NSMutableDictionary dictionary];
        _waitingObjects = [NSMutableDictionary dictionary];
        _commands = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Subscript

- (id)objectForKeyedSubscript:(id)key {
    if ([key isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    return _reflectObjects[key];
}

- (void)setObject:(id<ReflectBridgeExport>)object forKeyedSubscript:(id<NSCopying>)aKey {
    if ([object conformsToProtocol:objc_getProtocol("ReflectBridgeExport")] == NO) {
        NSLog(@"object not conform to protocol ReflectBridgeExport");
        return;
    }
    
    if (_injectJsFinished) {
        _reflectObjects[aKey] = object;
        [self bridgeObjectToJs:object name:(NSString *)aKey];
    } else {
        _waitingObjects[aKey] = object;
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
    if ([request.URL.scheme isEqualToString:ReflectScheme]) {
        if ([request.URL.host isEqualToString:ReflectInjectJs]) {
            [self injectJs];
        } else if ([request.URL.host isEqualToString:ReflectReadyForMessage]) {
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

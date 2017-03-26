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
#import "RJBUIWebViewBridge.h"
#import "RJBWKWebViewBridge.h"

@interface ReflectJavascriptBridge() <UIWebViewDelegate>

@property (nonatomic) NSMutableDictionary<NSString *, id> *reflectObjects;
@property (nonatomic) NSMutableDictionary<NSString *, id> *waitingObjects; // wait for bridge
@property (nonatomic) NSMutableDictionary<NSString *, id> *bridgedBlocks;
@property (nonatomic) NSMutableArray<RJBCommand *> *commands;
@property (nonatomic) BOOL injectJsFinished;

@end

@implementation ReflectJavascriptBridge

+ (ReflectJavascriptBridge *)bridge:(id)webView delegate:(id)delegate {
    if ([webView isKindOfClass:[UIWebView class]]) {
        return [[RJBUIWebViewBridge alloc] initWithWebView:webView delegate:delegate];
    } else if ([webView isKindOfClass:[WKWebView class]]) {
        return [[RJBWKWebViewBridge alloc] initWithWebView:webView delegate:delegate];
    } else {
        NSLog(@"[RJB]: webView should be `UIWebView` or `WKWebView`");
        return nil;
    }
}

+ (ReflectJavascriptBridge *)bridge:(id)webView {
    return [ReflectJavascriptBridge bridge:webView delegate:nil];
}

- (void)callJs:(NSString *)js completionHandler:(void (^)(id, NSError *))handler {
    NSLog(@"[RJB]: implement `callJs:completionHandler:` in subclass");
}

- (void)callJsMethod:(NSString *)methodName withArgs:(NSArray *)args completionHandler:(void (^)(id, NSError *))handler {
    NSLog(@"[RJB]: implement `callJsMethod:withArgs:completionHandler:` in subclass");
}

#pragma mark - Private method

/**
 向JS中注册一个Native对象

 @param obj  native的对象实例或block
 @param name 实例名称
 */
- (void)bridgeObjectToJs:(id)obj name:(NSString *)name {
    NSString *jsObj = [self convertNativeObjectToJs:obj identifier:name];
    NSString *js = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.addObject(%@,\"%@\");", jsObj, name];
    [self callJs:js completionHandler:nil];
}

/**
 将一个native对象转换成JS对象的表示

 @param object native对象实例
 @return       一段描述JS对象的JS代码
 */
- (NSString *)convertNativeObjectToJs:(id)object identifier:(NSString *)identifier {
    NSString *jsObject = [RJBObjectConvertor convertToJs:object identifier:identifier];
    return jsObject;
}

/**
 从JS中获取待执行的command对象
 */
- (void)fetchQueueingCommands {
    [self callJs:@"window.ReflectJavascriptBridge.dequeueCommandQueue();" completionHandler:^(id result, NSError *error) {
        NSString *json = (NSString *)result;
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
    }];
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
    [self callJs:ReflectJavascriptBridgeInjectedJS() completionHandler:^(id result, NSError *error) {
        if (!error) {
            _injectJsFinished = YES;
            [_waitingObjects enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<ReflectBridgeExport>  _Nonnull obj, BOOL * _Nonnull stop) {
                [self setObject:obj forKeyedSubscript:key];
            }];
            [_waitingObjects removeAllObjects];
        } else {
            NSLog(@"[RJB]: inject js code fail: %@", error);
        }
    }];
}

- (void)setLogEnable:(BOOL)logEnable {
    rjb_logEnable = logEnable;
}

#pragma mark - Initialize

- (instancetype)init {
    self = [super init];
    if (self) {
        _reflectObjects = [NSMutableDictionary dictionary];
        _waitingObjects = [NSMutableDictionary dictionary];
        _bridgedBlocks = [NSMutableDictionary dictionary];
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

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey {
    if (![object conformsToProtocol:objc_getProtocol("ReflectBridgeExport")] && ![object isKindOfClass:NSClassFromString(@"NSBlock")]) {
        NSLog(@"[RJB]: object should be a block or confirms to ReflectBridgeExport");
        return;
    }
    
    if (_injectJsFinished) {
        _reflectObjects[aKey] = object;
        [self bridgeObjectToJs:object name:(NSString *)aKey];
    } else {
        _waitingObjects[aKey] = object;
    }
}

@end

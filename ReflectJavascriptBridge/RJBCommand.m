//
//  RJBCommand.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBCommand.h"
#import <objc/runtime.h>

@interface RJBCommand()

@property (nonatomic) NSString *className;
@property (nonatomic) NSString *methodName;
@property (nonatomic, copy) NSArray *args;
@property (nonatomic) NSString *returnType;
@property (nonatomic) NSString *callbackId;

@end

@implementation RJBCommand

+ (RJBCommand *)commandWithDic:(NSDictionary *)dic {
    NSString *clsName = dic[@"className"];
    NSString *method = dic[@"method"];
    NSString *identifier = dic[@"identifier"];
    NSArray *args = dic[@"args"];
    NSString *returnType = dic[@"returnType"];
    NSString *callbackId = dic[@"callbackId"];
    
    if (clsName.length == 0 || method.length == 0) {
        return nil;
    }
    
    // 类或方法不存在
    Class cls = objc_getClass([clsName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (cls == nil) {
        return nil;
    }
    // TODO: 暂时只考虑实例方法
//    if (class_respondsToSelector(cls, NSSelectorFromString(method)) == NO) {
//        return nil;
//    }
    
    return [[RJBCommand alloc] initWithClass:clsName
                                      method:method
                                  identifier:identifier
                                        args:args
                                  returnType:returnType
                                  callbackId:callbackId];
}

- (void)execWithInstance:(id<ReflectBridgeExport>)instance bridge:(ReflectJavascriptBridge *)bridge {
    NSInvocation *invocation = nil;
    
    // 查找方法
    SEL selector = NSSelectorFromString(_methodName);
    NSMethodSignature *sign = [[instance class] instanceMethodSignatureForSelector:selector];
    if (sign) { // 存在实例方法
        invocation = [NSInvocation invocationWithMethodSignature:sign];
        invocation.target = instance;
    } else { // 否则查找类方法
        NSMethodSignature *classSign = [[instance class] methodSignatureForSelector:selector];
        if (classSign) {
            invocation = [NSInvocation invocationWithMethodSignature:classSign];
            invocation.target = [instance class];
        } else {
            NSLog(@"method '%@' not implement in class '%@'", _methodName, _className);
            return;
        }
    }
    invocation.selector = selector;
    
    // 设置参数
    if (_args.count != 0) {
        NSInteger index = 2;
        for (id arg in _args) {
            if ([arg isKindOfClass:[NSString class]]) {
                NSString *param = (NSString *)arg;
                [invocation setArgument:&param atIndex:index];
            } else if ([arg isKindOfClass:[NSNumber class]]) {
                NSNumber *number = (NSNumber *)arg;
                const char *type = [number objCType];
                if (strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0) {
                    double param = [number doubleValue];
                    [invocation setArgument:&param atIndex:index];
                } else {
                    NSInteger param = [number integerValue];
                    [invocation setArgument:&param atIndex:index];
                }
            }
            ++index;
        }
    }
    
    // 执行方法
    [invocation invoke];
    
    // 接收返回值
    if (![_returnType isEqualToString:@"v"] && _callbackId != nil) {
        NSString *value = nil;
        if ([_returnType isEqualToString:@"@"]) {
            id ret = nil;
            [invocation getReturnValue:&ret];
            if ([ret isKindOfClass:[NSString class]]) {
                value = [NSString stringWithFormat:@"\"%@\"", (NSString *)ret];
            } else if ([ret isKindOfClass:[NSNumber class]]) {
                value = [NSString stringWithFormat:@"%@", (NSNumber *)ret];
            }
        } else if ([_returnType isEqualToString:@"f"]) {
            float ret = 0;
            [invocation getReturnValue:&ret];
            value = [NSString stringWithFormat:@"%g", ret];
        } else if ([_returnType isEqualToString:@"d"]) {
            double ret = 0;
            [invocation getReturnValue:&ret];
            value = [NSString stringWithFormat:@"%g", ret];
        } else {
            long long ret = 0;
            [invocation getReturnValue:&ret];
            value = [NSString stringWithFormat:@"%lld", ret];
        }
        
        NSString *callbackJs = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.callback(\"%@\",%@);", _callbackId, value];
        [bridge callJs:callbackJs];
    }
}

- (instancetype)initWithClass:(NSString *)className
                       method:(NSString *)methodName
                   identifier:(NSString *)identifier
                         args:(NSArray *)args
                   returnType:(NSString *)returnType
                   callbackId:(NSString *)callbackId {
    self = [super init];
    if (self) {
        _className = className;
        _methodName = methodName;
        _identifier = identifier;
        _args = args;
        _returnType = returnType;
        _callbackId = callbackId;
    }
    return self;
}

@end

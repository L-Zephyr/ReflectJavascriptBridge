//
//  RJBCommand.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBCommand.h"
#import "RJBCommons.h"
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
    

    BOOL isBlock = [clsName isEqualToString:@"NSBlock"];
    if (clsName.length == 0 || (method.length == 0 && !isBlock)) {
        return nil;
    }
    
    // 类不存在
    Class cls = objc_getClass([clsName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (cls == nil) {
        NSLog(@"[RJB]: class `%@` not exists!", clsName);
        return nil;
    }

    return [[RJBCommand alloc] initWithClass:clsName
                                      method:method
                                  identifier:identifier
                                        args:args
                                  returnType:returnType
                                  callbackId:callbackId];
}

- (void)execWithInstance:(id)instance bridge:(ReflectJavascriptBridge *)bridge {
    NSInvocation *invocation = nil;
    NSMethodSignature *sign = nil;
    NSInteger paramOffset;
    
    if ([_className isEqualToString:@"NSBlock"]) {
        sign = [NSMethodSignature signatureWithObjCTypes:RJB_signatureForBlock(instance)];
        invocation = [NSInvocation invocationWithMethodSignature:sign];
        invocation.target = instance;
        paramOffset = 1;
    } else {
        // 查找方法
        SEL selector = NSSelectorFromString(_methodName);
        paramOffset = 2;
        sign = [[instance class] instanceMethodSignatureForSelector:selector];
        if (sign) { // 存在实例方法
            invocation = [NSInvocation invocationWithMethodSignature:sign];
            invocation.target = instance;
        } else { // 否则查找类方法
            sign = [[instance class] methodSignatureForSelector:selector];
            if (sign) {
                invocation = [NSInvocation invocationWithMethodSignature:sign];
                invocation.target = [instance class];
            } else {
                NSLog(@"[RJB]: method '%@' not implement in class '%@'", _methodName, _className);
                return;
            }
        }
        invocation.selector = selector;
    }
    
    
    for (NSInteger paramIndex = paramOffset; paramIndex < [sign numberOfArguments]; ++paramIndex) {
        if (_args.count <= paramIndex - paramOffset) {
            break;
        }
        id arg = _args[paramIndex - paramOffset];
        NSString *type = [NSString stringWithUTF8String:[sign getArgumentTypeAtIndex:paramIndex]]; // expected type
        
        if ([arg isKindOfClass:[NSString class]]) {
            if (RJB_isClass(type)) {
                [invocation setArgument:&arg atIndex:paramIndex];
            } else if (RJB_isInteger(type) || RJB_isUnsignedInteger(type)) {
                long long param = [(NSString *)arg longLongValue];
                [invocation setArgument:&param atIndex:paramIndex];
            } else if (RJB_isFloat(type)) {
                double param = [(NSString *)arg doubleValue];
                [invocation setArgument:&param atIndex:paramIndex];
            } else {
                NSLog(@"[RJB]: argument not support type");
                return;
            }
        } else if ([arg isKindOfClass:[NSNumber class]]) {
            if (RJB_isClass(type)) {
                NSString *param = [NSString stringWithFormat:@"%@", (NSString *)arg];
                [invocation setArgument:&param atIndex:paramIndex];
            } else if (RJB_isInteger(type)) {
                long long param = [(NSNumber *)arg longLongValue];
                [invocation setArgument:&param atIndex:paramIndex];
            } else if (RJB_isUnsignedInteger(type)) {
                unsigned long long param = [(NSNumber *)arg unsignedLongLongValue];
                [invocation setArgument:&param atIndex:paramIndex];
            } else if (RJB_isFloat(type)) {
                double param = [(NSNumber *)arg doubleValue];
                [invocation setArgument:&param atIndex:paramIndex];
            } else {
                NSLog(@"[RJB]: argument not support type");
                return;
            }
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
        
        // 将返回值回调给JS
        NSString *callbackJs = [NSString stringWithFormat:@"window.ReflectJavascriptBridge.callback(\"%@\",%@);", _callbackId, value];
        [bridge callJs:callbackJs completionHandler:nil];
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

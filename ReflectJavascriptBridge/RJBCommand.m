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

@end

@implementation RJBCommand

+ (RJBCommand *)commandWithDic:(NSDictionary *)dic {
    NSString *clsName = dic[@"className"];
    NSString *method = dic[@"method"];
    NSString *identifier = dic[@"identifier"];
    NSArray *args = dic[@"args"];
    
    if (clsName.length == 0 || method.length == 0) {
        return nil;
    }
    
    // 类或方法不存在
    Class cls = objc_getClass([clsName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (cls == nil) {
        return nil;
    }
    // TODO: 暂时只考虑实例方法
    if (class_respondsToSelector(cls, NSSelectorFromString(method)) == NO) {
        return nil;
    }
    
    return [[RJBCommand alloc] initWithClass:clsName method:method identifier:identifier args:args];
}

- (void)exec:(id<ReflectBridgeExport>)instance {
    NSInvocation *invocation = nil;
    
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
                NSInteger param = [number integerValue];
                [invocation setArgument:&param atIndex:index];
            }
            ++index;
        }
    }
    
    [invocation invoke];
}

- (instancetype)initWithClass:(NSString *)className
                       method:(NSString *)methodName
                   identifier:(NSString *)identifier
                         args:(NSArray *)args {
    self = [super init];
    if (self) {
        _className = className;
        _methodName = methodName;
        _identifier = identifier;
        _args = args;
    }
    return self;
}

@end

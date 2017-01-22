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
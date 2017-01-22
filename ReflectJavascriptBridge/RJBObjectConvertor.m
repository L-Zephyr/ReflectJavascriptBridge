//
//  RJBObjectConvertor.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBObjectConvertor.h"
#import <objc/runtime.h>

@interface RJBObjectConvertor()

@property (nonatomic) NSMutableString *js;

@end

@implementation RJBObjectConvertor

+ (NSString *)convertToJs:(id<ReflectBridgeExport>)object moduleId:(NSUInteger)moduleId {
    RJBObjectConvertor *convertor = [[RJBObjectConvertor alloc] initWithObject:object moduleId:moduleId];
    return [convertor toJs];
}

- (instancetype)initWithObject:(id<ReflectBridgeExport>)object moduleId:(NSUInteger)moduleId {
    self = [super init];
    if (self) {
        _js = [[NSMutableString alloc] init];
        [_js appendString:@"{"];
        
        // 找到所有实现了ReflectBridgeExport的协议
        NSMutableArray<Protocol *> *exportProtocols = [NSMutableArray array];
        unsigned int outCount = 0;
        Protocol * __unsafe_unretained *protos = class_copyProtocolList(object_getClass(object), &outCount);
        for (unsigned int index = 0; index < outCount; ++index) {
            Protocol *proto = protos[index];
            if (protocol_conformsToProtocol(proto, objc_getProtocol("ReflectBridgeExport"))) {
                [exportProtocols addObject:proto];
            }
        }
        
        // 获取方法名
        NSArray<NSString *> *methods = [self fetchMethodsFromProtocols:exportProtocols];
        
        NSMutableDictionary *methodMaps = [NSMutableDictionary dictionary]; // js方法名到native方法名的映射
        NSString *moduleName = [NSString stringWithUTF8String:class_getName(object_getClass(object))];
        [_js appendFormat:@"moduleName:\"%@\",", moduleName];
        [_js appendFormat:@"moduleId:%lu,", (unsigned long)moduleId];
        
        for (NSString *nativeMethod in methods) {
            NSArray *methodInfo = [self convertNativeMethodToJs:nativeMethod];
            NSString *methodName = methodInfo.firstObject;
            NSString *methodParam = methodInfo.count > 1 ? methodInfo[1] : nil;
            NSString *methodBody = [self jsMethodBodyWithName:methodName];
            
            [_js appendFormat:@"%@:function(%@){%@},", methodName, methodParam, methodBody];
            [methodMaps setObject:methodName forKey:nativeMethod];
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:methodMaps options:NSJSONWritingPrettyPrinted error:nil];
        if (data.length != 0) {
            [_js appendFormat:@"maps:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
        
        [_js appendString:@"}"];
    }
    return self;
}

- (NSString *)toJs {
    return _js;
}

#pragma mark - Helper

/**
 获取协议中定义的所有方法的名称

 @param protoList 包含Protocol的数组
 @return          方法名数组
 */
- (NSArray<NSString *> *)fetchMethodsFromProtocols:(NSArray<Protocol *> *)protoList {
    NSMutableArray<NSString *> *methods = [NSMutableArray array];
    for(Protocol *proto in protoList) {
        NSArray *isRequire = @[@(YES), @(YES), @(NO), @(NO)];
        NSArray *isInstance = @[@(YES), @(NO), @(YES), @(NO)];
        unsigned int count = 0;
        
        for (int index = 0; index < 4; ++index) {
            struct objc_method_description *desList = protocol_copyMethodDescriptionList(proto, [isRequire[index] boolValue], [isInstance[index] boolValue], &count);
            
            for (int desIndex = 0; desIndex < count; ++desIndex) {
                struct objc_method_description des = desList[desIndex];
                [methods addObject:[NSString stringWithUTF8String:sel_getName(des.name)]];
            }
        }
    }
    return [methods copy];
}

- (NSString *)jsMethodBodyWithName:(NSString *)methodName {
    return [NSString stringWithFormat:@"window.ReflectJavascriptBridge.sendCommand(this, \"%@\", arguments);", methodName];
}

/**
 返回转换后的JS方法名和参数

 @param nativeMethod native方法名
 @return 数组类型，包含JS方法名和参数(如果有参数)
 */
- (NSArray<NSString *> *)convertNativeMethodToJs:(NSString *)nativeMethod {
    NSArray<NSString *> *componenet = [nativeMethod componentsSeparatedByString:@":"];
    if (componenet.count == 0) {
        return @[nativeMethod];
    }
    
    NSMutableString *methodName = [NSMutableString string];
    NSMutableArray *params = [NSMutableArray array];
    [methodName appendString:componenet[0]];
    
    // 参数名组装在一起作为js的方法名
    for (int index = 1; index < componenet.count; ++index) {
        [methodName appendString:[self capitalizedFirst:componenet[index]]];
        [params addObject:[NSString stringWithFormat:@"p%d", index]];
    }
    
    // 参数
    NSMutableString *paramStr = [NSMutableString string];
    for (int index = 0; index < params.count; ++index) {
        NSString *param = params[index];
        [paramStr appendString:param];
        if (index != params.count - 1) {
            [paramStr appendString:@","];
        }
    }
    
    return @[methodName, paramStr];
}

/**
 将字符串的首字母大写

 @param string 原字符串
 @return       处理后的字符创
 */
- (NSString *)capitalizedFirst:(NSString *)string {
    if (string.length == 0) {
        return string;
    }
    NSString *first = [string substringWithRange:NSMakeRange(0, 1)];
    NSString *left = [string substringFromIndex:1];
    return [NSString stringWithFormat:@"%@%@", [first uppercaseString], left];
}

@end

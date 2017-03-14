//
//  RJBCommons.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef JSExoprtAs
#define JSExportAs(PropertyName, Selector) \
@optional Selector __JS_EXPORT_AS__##PropertyName:(id)argument; @required Selector
#endif

#define RJBLog(...) if(rjb_logEnable) NSLog(__VA_ARGS__);

static NSString *const RJBScheme = @"reflectjavascriptbridge";
static NSString *const RJBReadyForMessage = @"_ReadyForCommands_";
static NSString *const RJBInjectJs = @"_InjectJs_";
static NSString *const RJBBlockClassName = @"_NativeBlock_";

static BOOL rjb_logEnable = YES;

@protocol ReflectBridgeExport <NSObject>
// empty protocol
@end

// the js code to inject
NSString *ReflectJavascriptBridgeInjectedJS();

void RJB_log(NSString *log);

// 检测类型编码type是否为整型类型
BOOL RJB_isInteger(NSString *type);

// 检测类型编码type是否为无符号整型
BOOL RJB_isUnsignedInteger(NSString *type);

// 检测类型编码type是否为浮点类型
BOOL RJB_isFloat(NSString *type);

// 类型编码type是否为类
BOOL RJB_isClass(NSString *type);

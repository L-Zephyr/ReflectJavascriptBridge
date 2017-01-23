//
//  RJBCommons.h
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReflectBridgeExport <NSObject>

@end

// 注入的JS代码
NSString *ReflectJavascriptBridgeInjectedJS();

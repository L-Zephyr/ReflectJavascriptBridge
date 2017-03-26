//
//  RJBCommons.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBCommons.h"

#define ReflectJSCode(x) #x

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;     // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        // void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        // void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        // const char *signature;                         // IFF (1<<30)
        void* rest[1];
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

NSString *ReflectJavascriptBridgeInjectedJS() {
    return @ReflectJSCode(
                          ;(function() {
        'use strict';
        if (window.ReflectJavascriptBridge) {
            return;
        }
        
        window.ReflectJavascriptBridge = {
        addObject: addObject,
        dequeueCommandQueue: dequeueCommandQueue,
        sendCommand: sendCommand,
        checkAndCall: checkAndCall,
        callback: callback
        };
        
        var nativeObjects = [];
        var commandQueue = [];
        var responseCallbacks = [];
        var uniqueCallbackId = 0;
        var iFrame;
        var requestMessage = "ReflectJavascriptBridge://_ReadyForCommands_";
        
        if (window.RJBRegisteredFunctions) {
            var index;
            for (index in window.RJBRegisteredFunctions) {
                var funcInfo = window.RJBRegisteredFunctions[index];
                window.ReflectJavascriptBridge[funcInfo.name] = funcInfo.func;
            }
            delete window.RJBRegisteredFunctions;
        }
        
        function checkAndCall(methodName, args) {
            var method = window.ReflectJavascriptBridge[methodName];
            if (method && typeof method === 'function') {
                method.apply(null, args);
            }
        }
        
        function callback(callbackId, returnValue) {
            if (responseCallbacks[callbackId]) {
                responseCallbacks[callbackId](returnValue);
                delete responseCallbacks[callbackId];
            }
        }
        
        // 用json描述一个对象，name为变量的命名
        function addObject(objc, name) {
            nativeObjects[name] = objc;
            window.ReflectJavascriptBridge[name] = objc;
        }
        
        // 有新的command时向native发送消息,通知native获取command
        function sendReadyToNative() {
            iFrame.src = requestMessage;
        }
        
        // 该方法由native调用，返回所有的commands
        function dequeueCommandQueue() {
            var json = JSON.stringify(commandQueue);
            commandQueue = [];
            return json;
        }
        
        // 添加一条command并通知native
        function sendCommand(objc, method, args, returnType) {
            var command = {
                "className": objc["className"],
                "identifier": objc["identifier"],
                "args": args,
                "returnType": returnType
            };
            if (method) {
                command["method"] = objc.maps[method];
            }
            
            var lastArg = args[args.length - 1];
            if (returnType != 'v' && typeof lastArg === 'function') {
                responseCallbacks[uniqueCallbackId] = lastArg;
                command["callbackId"] = uniqueCallbackId; ++uniqueCallbackId;
            }
            commandQueue.push(command);
            sendReadyToNative();
        }
        
        // 添加一个iFrame用于发送信息
        iFrame = document.createElement("iframe");
        iFrame.style.display = 'none';
        iFrame.src = requestMessage;
        document.documentElement.appendChild(iFrame)
    })();
    );
}

BOOL RJB_isInteger(NSString *type) {
    NSString *intEncoding = @"cislq";
    return type.length == 1 && [intEncoding containsString:type];
}

BOOL RJB_isUnsignedInteger(NSString *type) {
    NSString *unsignedIntEncoding = @"CISLQ";
    return type.length == 1 && [unsignedIntEncoding containsString:type];
}

BOOL RJB_isFloat(NSString *type) {
    NSString *floatEncoding = @"fd";
    return type.length == 1 && [floatEncoding containsString:type];
}

BOOL RJB_isClass(NSString *type) {
    return [type hasPrefix:@"@"];
}

const char *RJB_signatureForBlock(id block) {
    struct Block_literal_1 *blockStruct = (__bridge void *)block;
    struct Block_descriptor_1 *descriptor = blockStruct->descriptor;
    if (blockStruct->flags & BLOCK_HAS_SIGNATURE) {
        int offset = 0;
        if(blockStruct->flags & BLOCK_HAS_COPY_DISPOSE)
            offset += 2;
        return (char*)(descriptor->rest[offset]);
    } else {
        return nil;
    }
}

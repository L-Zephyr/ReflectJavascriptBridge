//
//  RJBCommons.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/23.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "RJBCommons.h"

#define ReflectJSCode(x) #x

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
                window.ReflectJavascriptBridge[method].apply(null, args);
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
            var callback = args[args.length - 1];
            var callbackId = uniqueCallbackId;
            if (returnType != 'v' && typeof callback === 'function') {
                responseCallbacks[callbackId] = callback;
                ++uniqueCallbackId;
            }
            var command = {
                "className": objc["className"], // 这个是Export的类名
                "identifier": objc["identifier"], // 唯一的ID,这个ID是实例对象的名称
                "method": objc.maps[method], // 调用的方法名
                "args": args, // 参数
                "returnType": returnType, // 返回值类型
                "callbackId": callbackId
            };
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


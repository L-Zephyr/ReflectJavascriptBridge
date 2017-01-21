//
//  Command.swift
//  Reflect
//
//  Created by LZephyr on 2017/1/14.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

class Command: NSObject {
    
    // MARK: - Public
    
    /// 创建一条指令
    ///
    /// - Parameters:
    ///   - clsName: 类名
    ///   - methodName: 方法
    ///   - args: 参数数组
    internal static func command(clsName: String, methodName: String, args: [Any]) -> Command? {
        if clsName.isEmpty || methodName.isEmpty {
            return nil
        }
        
        guard let cls = objc_getClass(clsName) as? AnyClass else {
            print("class \(clsName) not exist")
            return nil
        }
        
        // todo: 只判断实例方法
        if class_respondsToSelector(cls, NSSelectorFromString(methodName)) == false {
            print("class \(clsName) not respond to \(methodName)")
            return nil
        }
        
        return Command(clsName: clsName, methodName: methodName, args: args)
    }
    
    /// 执行指令
    internal func exec() {
        
    }
    
    // MARK: - Private
    
    fileprivate var cls: String = ""
    fileprivate var method: String = ""
    fileprivate var args: [Any] = []
    
    
    fileprivate init(clsName: String, methodName: String, args: [Any]) {
        super.init()
        self.cls = clsName
        self.method = methodName
        self.args = args
    }
}

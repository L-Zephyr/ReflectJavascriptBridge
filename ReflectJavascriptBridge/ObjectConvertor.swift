//
//  ObjectConvertor.swift
//  Reflect
//
//  Created by LZephyr on 2017/1/20.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

internal class ObjectConvertor {
    static func convertToJs(_ object: ReflectExport, moduleId: Int) -> String {
        let convertor = ObjectConvertor(object: object, moduleId: moduleId)
        return convertor.toJs()
    }
    
    // MARK: - Private 
    
    fileprivate var js: String = ""
    
    init(object: ReflectExport, moduleId: Int) {
        js.append("{")
        // 找到所有继承自ReflectExport的协议
        var exportProtocols: [Protocol] = []
        var proCount: UInt32 = 0
        if let proList = class_copyProtocolList(object_getClass(object), &proCount) {
            for index in 0..<numericCast(proCount) {
                if let proto = proList[index] {
                    if protocol_conformsToProtocol(proto, ReflectExport.self) {
                        exportProtocols.append(proto)
                    }
                }
            }
        }
        
        // TODO: 暂时先不考虑属性
//        var ivarList: [String] = fetchPropertiesFrom(exportProtocols)
        var methodList: [String] = fetchMethodsFrom(exportProtocols)
        
        // 类名作为moduleName
        var methodMaps: [String: String] = [:] // js方法名到native方法名的映射
        let moduleName = String(cString: class_getName(object_getClass(object)))
        js.append("moduleName:\"\(moduleName)\",")
        js.append("moduleId:\(moduleId),")
        
        for method in methodList {
            let (jsMethod, methodParam) = convertNativeMethodToJs(method)
            js.append("\(jsMethod):function(\(methodParam)){},")
            methodMaps[jsMethod] = method
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: methodMaps, options: .prettyPrinted), let mapsStr = String(data: data, encoding: .utf8) {
            js.append("maps:\(mapsStr)")
        }
        
        js.append("}")
    }
    
    fileprivate func toJs() -> String {
        return js
    }
    
    // 获取Protocol列表中所有的属性名
    func fetchPropertiesFrom(_ protocols: [Protocol]) -> [String] {
        var properties: [String] = []
        for proto in protocols {
            var ivarCount: UInt32 = 0
            if let propertyList = protocol_copyPropertyList(proto, &ivarCount) {
                for index in 0..<numericCast(ivarCount) {
                    let ivar = propertyList[index]
                    properties.append(String(cString: property_getName(ivar)))
                }
            }
        }
        return properties
    }
    
    // 获取Protocol列表中所有的方法名
    func fetchMethodsFrom(_ protocols: [Protocol]) -> [String] {
        var methods: [String] = []
        for proto in protocols {
            var count: UInt32 = 0
            var isRequire: [Bool] = [true, true, false, false]
            var isInstance: [Bool] = [true, false, true, false]
            for i in 0..<4 {
                if let methodList = protocol_copyMethodDescriptionList(proto, isRequire[i], isInstance[i], &count) {
                    for index in 0..<numericCast(count) {
                        let method = methodList[index]
                        methods.append(String(cString: sel_getName(method.name)))
                    }
                }
            }
        }
        return methods
    }
    
    // 将方法名转换成js中的方法名
    func convertNativeMethodToJs(_ nativeMethod: String) -> (String, String) {
        let components = nativeMethod.components(separatedBy: ":")
        if components.count == 0 {
            return ("", "")
        }
        
        var methodName = components[0]
        var params: [String] = []
        
        // 参数名组装在一起作为方法名
        for index in 1..<components.count {
            methodName.append(components[index].capitalizedFirst())
            params.append("p\(index)")
        }
        
        // 参数
        var paramStr: String = ""
        for index in 0..<params.count {
            let param = params[index]
            paramStr.append(param)
            if index != (params.count - 1) {
                paramStr.append(",")
            }
        }
        
        return (methodName, paramStr)
    }
}

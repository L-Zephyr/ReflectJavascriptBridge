//
//  ReflectJavascriptBridge.swift
//  Reflect
//
//  Created by LZephyr on 2017/1/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

class ReflectJavascriptBridge: NSObject {
    
    // 通过下标语法来向JS反射
    @objc public subscript (name: String) -> ReflectExport? {
        set {
            if let newValue = newValue { // Native中会保留一份引用,name相同则会覆盖
                reflectObjects[name] = newValue
                bridgeObjectToJs(newValue) // 注入对象
            } else if reflectObjects.keys.contains(name) {
                reflectObjects.removeValue(forKey: name)
            }
        }
        get {
            return reflectObjects[name]
        }
    }
    
    public static func bridge(_ webView: UIWebView, delegate: UIWebViewDelegate?) -> ReflectJavascriptBridge {
        let bridge = ReflectJavascriptBridge()
        bridge.setupWebView(webView, delegate: delegate)
        return bridge
    }
    
    public static func bridge(_ webView: UIWebView) -> ReflectJavascriptBridge {
        let bridge = ReflectJavascriptBridge()
        bridge.setupWebView(webView, delegate: nil)
        return bridge
    }
    
    // MARK: - Private
    
    fileprivate var reflectObjects: [String : ReflectExport] = [:]
    fileprivate var commands: [Command] = []
    fileprivate var uniqueModuleId: Int = 0
    fileprivate var delegate: UIWebViewDelegate?
    fileprivate var webView: UIWebView?
    
    /// 向JS中注入一个对象
    ///
    /// - Parameter obj: 桥接到JS中的对象
    fileprivate func bridgeObjectToJs(_ obj: ReflectExport) {
        let js = convertNativeObjectToJs(obj)
        _ = webView?.stringByEvaluatingJavaScript(from: "window.ReflectJavascriptBridge.addObject(\(js))")
    }
    
    /// 将一个对象转换成js
    ///
    /// - Parameter object: 待转换的对象
    /// - Returns:          json
    fileprivate func convertNativeObjectToJs(_ object: ReflectExport) -> String {
        let jsObject = ObjectConvertor.convertToJs(object, moduleId: uniqueModuleId)
        uniqueModuleId = uniqueModuleId + 1
        return jsObject
    }
    
    fileprivate func setupWebView(_ webView: UIWebView, delegate: UIWebViewDelegate?) {
        self.delegate = delegate
        self.webView = webView
        webView.delegate = self
    }
    
    /// 从JS中获取待执行的操作
    fileprivate func fetchQueueingOperations() {
        // ...
        execCommands()
    }
    
    /// 从js中获取json格式的消息并执行
    fileprivate func execCommands() {
        if commands.isEmpty {
            return
        }
        
        for command in commands {
            command.exec()
        }
    }
    
    // MARK: - Helper
    
}

extension ReflectJavascriptBridge: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if let delegate = delegate, delegate.responds(to: #selector(UIWebViewDelegate.webViewDidStartLoad(_:))) {
            delegate.webViewDidFinishLoad!(webView)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let delegate = delegate, delegate.responds(to: #selector(UIWebViewDelegate.webViewDidFinishLoad(_:))) {
            delegate.webViewDidFinishLoad!(webView)
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if let delegate = delegate, delegate.responds(to: #selector(UIWebViewDelegate.webView(_:didFailLoadWithError:))) {
            delegate.webView!(webView, didFailLoadWithError: error)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}

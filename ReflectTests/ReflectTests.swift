//
//  ReflectTests.swift
//  ReflectTests
//
//  Created by LZephyr on 2017/1/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest
@testable import ReflectJavascriptBridge

class JSObject: NSObject, ReflectExport {
    var name: String?
    var age: String = ""
    func function(withName name: String, age: Int) {
        print("\(name)")
    }
    
    init(_ name: String) {
        super.init()
        self.name = name
    }
}

class ReflectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testNativeObjConvertToJs() {
        let obj = JSObject("wind")
        let webview = UIWebView()
        let bridge = ReflectJavascriptBridge.bridge(webview)
    }
}

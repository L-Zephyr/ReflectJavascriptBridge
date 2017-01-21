//
//  ExtensionTest.swift
//  Reflect
//
//  Created by LZephyr on 2017/1/20.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest
@testable import Reflect

class ExtensionTest: XCTestCase {
    
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCapitalizedFirst() {
        let testCase = "functionWithName"
        let result = testCase.capitalizedFirst()
        XCTAssert(result == "FunctionWithName", result)
    }
}

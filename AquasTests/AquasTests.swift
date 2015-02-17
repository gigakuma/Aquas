//
//  AquasTests.swift
//  AquasTests
//
//  Created by Qiang on 2/16/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import UIKit
import XCTest
import Aquas

class AquasTests: XCTestCase {
    
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
        var x: AQGLTexture2D? = nil
        var format: AQGLTexture2DPixelFormat = .RGBA8
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

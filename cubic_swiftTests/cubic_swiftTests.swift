//
//  cubic_swiftTests.swift
//  cubic_swiftTests
//
//  Created by Forsad Al Hossain on 8/5/16.
//  Copyright © 2016 Cobalt Speech & Language Inc. All rights reserved.
//

import XCTest
import cubic_swift

class cubic_swiftTests: XCTestCase {
    
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
        let testOb:AudioRecorder = AudioRecorder()
        let opQ = NSOperationQueue();
        let rand_arr = (1...100).map{_ in arc4random_uniform(2)};
        for element in rand_arr
        {
            if element == 0
            {
                opQ.addOperationWithBlock{testOb.startRecording("not-model",block:true)} //did not load any model,just
                                                                                                // doing that for testing
            }
            else
            {
                opQ.addOperationWithBlock{testOb.stop()}
            }
        }
        opQ.waitUntilAllOperationsAreFinished();
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

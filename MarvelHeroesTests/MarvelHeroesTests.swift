//
//  MarvelHeroesTests.swift
//  MarvelHeroesTests
//
//  Created by Mingu Chu on 9/3/16.
//  Copyright © 2016 Mingu Chu. All rights reserved.
//

import XCTest
import UIKit
import AFNetworking

@testable import MarvelHeroes

class MarvelHeroesTests: XCTestCase {
    
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
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testCharacterAPIRequest() {
        for i in 0 ..< 5 {
            let expectation = expectationWithDescription("Testing Characters loading for page: " + i.description)
            
            APIManager.sharedInstance.getHeroes(i, success: { (operation, characters) in
                XCTAssertTrue(characters.count == 12, "No more characters to load at page: " + i.description)
                expectation.fulfill()
            }) { (operation, error) in
                XCTFail("Load characters failed with error: " + error.description)
            }
            
            waitForExpectationsWithTimeout(10.0, handler: { error in XCTAssertNil(error, "Expectation failed with error: " + (error?.description)!)})
        }
    }
}

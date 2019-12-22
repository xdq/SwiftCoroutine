//
//  CoFutureTests.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 20.12.2019.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import XCTest
import SwiftCoroutine

class CoFutureTests: XCTestCase {
    
    func testTransform() {
        let expectation = XCTestExpectation(description: "Test Transform")
        expectation.expectedFulfillmentCount = 3
        let promise = async { () -> Int in
            sleep(1)
            return 1
        }
        var transformed: CoFuture<String>! = promise
            .mapOutput { $0 * 2 }
            .onError { _ in XCTFail() }
            .mapOutput { $0 * 3 }
            .onSuccess { XCTAssertEqual($0, 6) }
            .onSuccess { _ in expectation.fulfill() }
            .mapOutput { $0.description }
            .onResult { expectation.fulfill() }
        weak var weakTransformed: CoFuture<String>? = transformed
        transformed.onResult(queue: .global()) {
            transformed = nil
            XCTAssertNil(weakTransformed)
            XCTAssertEqual(try? $0.get(), "6")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
}
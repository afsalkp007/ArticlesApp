//
//  XCTestCase+MemoryLeakTracking.swift
//  ArticlesTests
//
//  Created by Afsal on 02/06/2024.
//

import XCTest

extension XCTestCase {
  func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, file: file, line: line)
    }
  }
}

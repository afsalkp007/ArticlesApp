//
//  URLSessionHTTPClientTests.swift
//  ArticlesTests
//
//  Created by Afsal on 01/06/2024.
//

import XCTest
import Foundation

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession) {
    self.session = session
  }
  
  func get(from url: URL) {
    session.dataTask(with: url) { _, _, _ in }.resume()
  }
}

class URLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_createsDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(session.receivedURLs, [url])
  }
  
  func test_getFromURL_resumesDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    session.stub(url: url, task: task)
    let sut = URLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
  
  // MARK: - Helpers
  
  private class URLSessionSpy: URLSession {
    var receivedURLs = [URL]()
    var stub = [URL: URLSessionDataTask]()
    
    func stub(url: URL, task: URLSessionDataTaskSpy) {
      stub[url] = task
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)
      return stub[url] ?? FakeURLSessionDataTask()
    }
  }
  
  private class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount = 0
    
    override func resume() {
      resumeCallCount += 1
    }
  }
  
  private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
  }
}

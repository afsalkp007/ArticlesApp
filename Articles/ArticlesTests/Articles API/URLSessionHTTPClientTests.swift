//
//  URLSessionHTTPClientTests.swift
//  ArticlesTests
//
//  Created by Afsal on 01/06/2024.
//

import XCTest
import Articles

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { _, _, error in
      if let error = error {
        completion(.failure(error))
      }
    }.resume()
  }
}

class URLSessionHTTPClientTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    URLProtocolStub.startInterceptingRequests()
  }
  
  override func tearDown() {
    super.tearDown()
    
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func test_getFromURL_deliversErrorOnClientError() {
    URLProtocolStub.startInterceptingRequests()
    let url = URL(string: "http://any-url.com")!
    let error = NSError(domain: "any error", code: 1)
    URLProtocolStub.stub(data: nil, response: nil, error: error)
        
    let exp = expectation(description: "Wait for completion")
    
    makeSUT().get(from: url) { result in
      switch result {
      case let .failure(receivedError as NSError):
        XCTAssertEqual(receivedError.domain, error.domain)
        XCTAssertEqual(receivedError.code, error.code)
        
      default:
        XCTFail("Expected error: \(error), got \(result) instead.")
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_performsGETRequestWithURL() {
    let url = URL(string: "http://any-url.com")!
    
    let exp = expectation(description: "Wait for request")

    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()
    }
    
    makeSUT().get(from: url) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  // MARK: - Helpers
  
  private func makeSUT() -> URLSessionHTTPClient {
    return URLSessionHTTPClient()
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    struct Stub {
      let data: Data?
      let response: HTTPURLResponse?
      let error: Error?
    }
    
    static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
      stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(_ request: @escaping (URLRequest) -> Void) {
      requestObserver = request
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}

//
//  RemoteArticlesLoaderTests.swift
//  ArticlesTests
//
//  Created by Afsal on 28/05/2024.
//

import XCTest
import Articles

class RemoteArticlesLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestsURL() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestsOnLoad() {
    let url = URL(string: "a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestsOnLoadTwice() {
    let url = URL(string: "a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    
    var receivedErrors = [RemoteArticlesLoader.Error]()
    sut.load { receivedErrors.append($0) }
    
    let clientError = NSError(domain: "Test", code: 0)
    client.complete(with: clientError)
    
    XCTAssertEqual(receivedErrors, [.connectivity])
  }
  
  func test_load_deliversErrorOnInvalidData() {
    let (sut, client) = makeSUT()
        
    [199, 201, 300, 400, 500].enumerated().forEach { index, code in
      var receivedErrors = [RemoteArticlesLoader.Error]()
      sut.load { receivedErrors.append($0) }

      client.complete(withStatusCode: code, at: index)
      
      XCTAssertEqual(receivedErrors, [.invalidData])
    }
  }
  
  // MARK: - Helpers
  
  private func makeSUT(url: URL = URL(string: "a-url.com")!) -> (sut: RemoteArticlesLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteArticlesLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class HTTPClientSpy: HTTPClient {
    var completions = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestedURLs: [URL] {
      return completions.map(\.url)
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      completions.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      completions[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
      completions[index].completion(.success(response))
    }
  }
}

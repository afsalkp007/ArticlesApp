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
    
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  // MARK: - Helpers
  
  private func makeSUT(url: URL = URL(string: "a-url.com")!) -> (sut: RemoteArticlesLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteArticlesLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()

    func get(from url: URL) {
      requestedURLs.append(url)
    }
  }
}

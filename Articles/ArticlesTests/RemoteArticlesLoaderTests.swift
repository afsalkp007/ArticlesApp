//
//  RemoteArticlesLoaderTests.swift
//  ArticlesTests
//
//  Created by Afsal on 28/05/2024.
//

import XCTest

class HTTPClient {
  var requestedURLs = [URL]()
  
  func get(from url: URL) {
    requestedURLs.append(url)
  }
}

class RemoteArticlesLoader {
  let url: URL
  let client: HTTPClient
  
  init(url: URL = URL(string: "a-url.com")!, client: HTTPClient) {
    self.url = url
    self.client = client
  }
  
  func load() {
    client.get(from: url)
  }
}

class RemoteArticlesLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestsURL() {
    let client = HTTPClient()
    _ = RemoteArticlesLoader(client: client)
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_init_requestsOnLoad() {
    let url = URL(string: "a-given-url.com")!
    let client = HTTPClient()
    let sut = RemoteArticlesLoader(url: url, client: client)
    
    sut.load()
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
}

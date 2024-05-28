//
//  RemoteArticlesLoaderTests.swift
//  ArticlesTests
//
//  Created by Afsal on 28/05/2024.
//

import XCTest

class HTTPClient {
  var requredURLs = [URL]()
}

class RemoteArticlesLoader {
  let client: HTTPClient
  
  init(client: HTTPClient) {
    self.client = client
  }
  
  func load() {
    
  }
}

class RemoteArticlesLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestURL() {
    let client = HTTPClient()
    _ = RemoteArticlesLoader(client: client)
    
    XCTAssertTrue(client.requredURLs.isEmpty)
  }
}

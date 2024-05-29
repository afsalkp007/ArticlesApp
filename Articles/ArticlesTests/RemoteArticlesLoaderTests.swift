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
    
    expect(sut, toExpectError: .failure(.connectivity), when: {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    })
  }
  
  func test_load_deliversErrorOnInvalidDataOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
        
    [199, 201, 300, 400, 500].enumerated().forEach { index, code in
      expect(sut, toExpectError: .failure(.invalidData), when: {
        client.complete(withStatusCode: code, at: index)
      })
    }
  }
  
  func test_load_deliversErrorOn200HTTPRespnseWithInvalidJSON() {
    let (sut, client) = makeSUT()
    
    expect(sut, toExpectError: .failure(.invalidData), when: {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    })
  }
  
  func test_load_deliversEmptyListOn200HTTPRespnseWithEmptyJSON() {
    let (sut, client) = makeSUT()
    
    expect(sut, toExpectError: .success([]), when: {
      let emptyJSON = Data("{\"results\": []}".utf8)
      client.complete(withStatusCode: 200, data: emptyJSON)
    })
  }
  
  func test_load_deliversItemsOn200HTTPRespnseWithItemsJSON() {
    let (sut, client) = makeSUT()
    
    let item1 = makeItem(
      title: "a title",
      byline: "a name",
      date: (Date(timeIntervalSince1970: 1716667200), "26 May 2024"),
      imageURL: URL(string: "http://a-url.com")!)
    
    let item2 = makeItem(
      title: "another title",
      byline: "another name",
      date: (Date(timeIntervalSince1970: 1707768000), "13 Feb 2024"),
      imageURL: URL(string: "http://another-url.com")!)

    let itemsJSON = ["results": [item1.json, item2.json]]
    let items = [item1.model, item2.model]
    
    expect(sut, toExpectError: .success(items), when: {
      let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
      client.complete(withStatusCode: 200, data: json)
    })
  }
  
  // MARK: - Helpers
  
  private func makeSUT(url: URL = URL(string: "a-url.com")!) -> (sut: RemoteArticlesLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteArticlesLoader(url: url, client: client)
    return (sut, client)
  }
  
  private func makeItem(title: String, byline: String, date: (date: Date, formatted: String), imageURL: URL) -> (model: ArticleItem, json: [String: Any]) {
    let item = ArticleItem(
      title: title,
      byline: byline,
      date: date.date,
      imageURL: imageURL)
    
    let json: [String: Any] = [
      "title": item.title,
      "byline": item.byline,
      "published_date": date.formatted,
      "media": [
        ["media-metadata": [["url": item.imageURL?.absoluteString]]]
      ]
    ]
    
    return (item, json)
  }
  
  private func expect(_ sut: RemoteArticlesLoader, toExpectError error: RemoteArticlesLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    var receivedResults = [RemoteArticlesLoader.Result]()
    sut.load { receivedResults.append($0) }

    action()
    
    XCTAssertEqual(receivedResults, [error], file: file, line: line)
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
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
      completions[index].completion(.success(data, response))
    }
  }
}

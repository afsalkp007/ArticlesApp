//
//  ArticlesAPIEndToEndTests.swift
//  ArticlesAPIEndToEndTests
//
//  Created by Afsal on 03/06/2024.
//

import XCTest
import Articles

class ArticlesAPIEndToEndTests: XCTestCase {
  
  func test_loadArticlesDeliversArticlesData() {
    switch getArticlesResult() {
    case let .success(items)?:
      XCTAssertEqual(items.count, 20)
      XCTAssertEqual(items[0], expectedItem(at: 0))
      XCTAssertEqual(items[1], expectedItem(at: 1))
      
    case let .failure(error)?:
      XCTFail("Expected success, got \(error) instead.")
      
    default:
      XCTFail("Expected success, got no result instead.")
    }
  }
  
  // MARK: - Helpers
  
  private func getArticlesResult(file: StaticString = #filePath, line: UInt = #line) -> ArticleResult? {
    let url = URL(string: "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/30.json?api-key=gGc5U7GM2xeyNgFlxJxf3qb0x8AfqLe5")!
    let client = URLSessionHTTPClient()
    let loader = RemoteArticlesLoader(url: url, client: client)
    trackForMemoryLeak(client, file: file, line: line)
    trackForMemoryLeak(loader, file: file, line: line)
    
    let exp = expectation(description: "Wait for load completion")
    
    var receivedResult: ArticleResult?
    loader.load { result in
      receivedResult = result
      exp.fulfill()
    }
    wait(for: [exp], timeout: 5.0)
    return receivedResult
  }
  
  private func expectedItem(at index: Int) -> ArticleItem {
    ArticleItem(title: title(at: index), byline: byline(at: index), date: date(at: index), imageURL: imageURL(at: index))
  }
  
  private func title(at index: Int) -> String {
    return [
      "A Shock of Red for a Royal Portrait",
      "These Couples Survived a Lot. Then Came Retirement."
    ][index]
  }
  
  private func byline(at index: Int) -> String {
    return [
      "By Vanessa Friedman",
      "By Susan Dominus"
    ][index]
  }
  
  private func date(at index: Int) -> Date {
    return ArticleItemsMapper.getFormattedDate([
      "2024-05-15",
      "2024-05-05"
    ][index])!
  }
  
  private func imageURL(at index: Int) -> URL {
    return URL(string: [
      "https://static01.nyt.com/images/2024/05/15/multimedia/15CHARLES-RED-lgvw/15CHARLES-RED-lgvw-thumbStandard.jpg",
      "https://static01.nyt.com/images/2024/05/12/magazine/12mag-couples/12mag-couples-thumbStandard.jpg"
    ][index])!
  }
}

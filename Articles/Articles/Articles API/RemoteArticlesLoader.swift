//
//  RemoteArticlesLoader.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public enum HTTPClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteArticlesLoader {
  let url: URL
  let client: HTTPClient
  
  public enum Result: Equatable {
    case success([ArticleItem])
    case failure(Error)
  }
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public init(url: URL = URL(string: "a-url.com")!, client: HTTPClient) {
    self.url = url
    self.client = client
  }
    
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { result in
      switch result {
      case let .success(data, response):
        do {
          let articles = try ArticleItemsMapper.map(data, response)
          completion(.success(articles))
        } catch {
          completion(.failure(.invalidData))
        }
        
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
}

private class ArticleItemsMapper {
  static var formatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateStyle = .medium
    dateFormatter.timeZone = .none
    return dateFormatter
  }
  
  private static var OK_200: Int { return 200 }

  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ArticleItem] {
    guard response.statusCode == OK_200 else {
      throw RemoteArticlesLoader.Error.invalidData
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(Self.formatter)
    let root = try decoder.decode(Root.self, from: data)
    return root.results.map(\.article)
  }
}

private struct Root: Decodable {
  let results: [Item]
}

private struct Item: Decodable {
  let title: String
  let byline: String
  let date: Date
  let media: [Media]
  
  var article: ArticleItem {
    return ArticleItem(title: title, byline: byline, date: date, imageURL: media.first?.mediaMetadata.first?.url)
  }
  
  private enum CodingKeys: String, CodingKey {
    case title
    case byline
    case date = "published_date"
    case media
  }
}

private struct Media: Decodable {
  let mediaMetadata: [MediaMetaData]
  
  private enum CodingKeys: String, CodingKey {
    case mediaMetadata = "media-metadata"
  }
}

private struct MediaMetaData: Decodable {
  let url: URL
}

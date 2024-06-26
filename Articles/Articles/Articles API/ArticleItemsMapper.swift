//
//  ArticleItemsMapper.swift
//  Articles
//
//  Created by Afsal on 29/05/2024.
//

import Foundation

public class ArticleItemsMapper {
  private struct Root: Decodable {
    let results: [Item]
    
    var articles: [ArticleItem] {
      return results.map(\.article)
    }
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
  
  private static var OK_200: Int { return 200 }
  
  static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteArticlesLoader.Result {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(getFormatter())
    
    guard response.statusCode == OK_200,
          let root = try? decoder.decode(Root.self, from: data) else {
      return .failure(RemoteArticlesLoader.Error.invalidData)
    }
    
    let articles = root.articles
    return .success(articles)
  }
  
  private static func getFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }
  
  public static func getFormattedDate(_ string: String) -> Date? {
    return getFormatter().date(from: string)
  }
}

//
//  RemoteArticlesLoader.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public class RemoteArticlesLoader: ArticleLoader {
  let url: URL
  let client: HTTPClient
  
  public typealias Result = ArticleResult
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }
    
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      switch result {
      case let .success(data, response):
        completion(ArticleItemsMapper.map(data, response))
        
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
}


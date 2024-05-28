//
//  RemoteArticlesLoader.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (Error) -> Void)
}

public class RemoteArticlesLoader {
  let url: URL
  let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
  }
  
  public init(url: URL = URL(string: "a-url.com")!, client: HTTPClient) {
    self.url = url
    self.client = client
  }
  
  public func load(completion: @escaping (Error) -> Void = { _ in }) {
    client.get(from: url) { error in
      completion(.connectivity)
    }
  }
}

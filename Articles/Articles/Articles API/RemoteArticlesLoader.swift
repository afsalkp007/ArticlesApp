//
//  RemoteArticlesLoader.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL)
}

public class RemoteArticlesLoader {
  let url: URL
  let client: HTTPClient
  
  public init(url: URL = URL(string: "a-url.com")!, client: HTTPClient) {
    self.url = url
    self.client = client
  }
  
  public func load() {
    client.get(from: url)
  }
}

//
//  ArticleItem.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public struct ArticleItem: Equatable {
  public let title: String
  public let byline: String
  public let date: Date
  public let imageURL: URL?
  
  public init(title: String, byline: String, date: Date, imageURL: URL?) {
    self.title = title
    self.byline = byline
    self.date = date
    self.imageURL = imageURL
  }
}

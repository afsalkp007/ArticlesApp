//
//  ArticleLoader.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public enum ArticleResult {
  case success([ArticleItem])
  case failure(Error)
}

protocol ArticleLoader {
  func load(completion: (ArticleResult) -> Void)
}

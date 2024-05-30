//
//  ArticleLoader.swift
//  Articles
//
//  Created by Afsal on 28/05/2024.
//

import Foundation

public enum ArticleResult<Error: Swift.Error> {
  case success([ArticleItem])
  case failure(Error)
}

extension ArticleResult: Equatable where Error: Equatable {}

protocol ArticleLoader {
  associatedtype Error: Swift.Error
  
  func load(completion: (ArticleResult<Error>) -> Void)
}

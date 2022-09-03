//
//  MovieList.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

struct MovieList {
    let page: Int
    let items: [MovieListItem]
    let totalPages: Int
    var section: HomeMovieLists? = nil
    
    var nextPage: Int? {
        let nextPage = self.page + 1
        guard nextPage < self.totalPages else {
            return nil
        }
        return nextPage
    }
}

struct MovieListItem: Hashable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String
    let originalLanguage: OriginalLanguage
    let genres: [Genre]
    let rating: Double
}

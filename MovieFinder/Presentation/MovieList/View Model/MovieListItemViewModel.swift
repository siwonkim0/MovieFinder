//
//  MovieListCollectionViewItemViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/04.
//

import Foundation

struct MovieListItemViewModel: Hashable {
    let id: Int
    let posterPath: String?
    let title: String?
    let originalLanguage: String
    let genres: String
    let section: MovieListURL
    
    init(movie: MovieListItem, section: MovieListURL) {
        self.id = movie.id
        self.posterPath = movie.posterPath
        self.title = movie.title
        self.originalLanguage = movie.originalLanguage.formatted
        self.genres = movie.genres.map {$0.name.uppercased()}
                                    .joined(separator: "/")
        self.section = section
    }
}

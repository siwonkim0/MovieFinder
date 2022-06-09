//
//  MovieListCollectionViewItemViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/04.
//

import Foundation

struct MovieListCollectionViewItemViewModel {
    let posterPath: String?
    let rating: Double?
    let title: String?
    let originalLanguage: String
    let genres: String
    
    init(movie: MovieListItem) {
        self.posterPath = movie.posterPath
        self.rating = movie.rating
        self.title = movie.title
        self.originalLanguage = movie.originalLanguage.formatted
        self.genres = movie.genres.map {$0.name.uppercased()}
                                    .joined(separator: "/")
    }
}

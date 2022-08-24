//
//  SearchCellViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/24.
//

import Foundation

struct SearchCellViewModel: Hashable {
    let id: Int
    let imageUrl: URL?
    let title: String
    let originalLanguage: String
    let genres: String
    let releaseDate: String
    
    init(movie: MovieListItem) {
        self.id = movie.id
        self.imageUrl = ImageRequest(urlPath: movie.posterPath).urlComponents
        self.title = movie.title
        self.originalLanguage = movie.originalLanguage.formatted
        self.genres = movie.genres
            .map {$0.name}
            .joined(separator: ", ")
        self.releaseDate = movie.releaseDate
    }
}

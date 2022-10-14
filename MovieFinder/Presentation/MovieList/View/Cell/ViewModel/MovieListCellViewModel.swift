//
//  MovieListCollectionViewItemViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/04.
//

import Foundation

struct MovieListCellViewModel: Hashable {
    let id: Int
    let imageUrl: URL?
    let title: String
    let originalLanguage: String
    let genres: String
    let section: HomeMovieLists
    
    init(movie: MovieListItem, section: HomeMovieLists) {
        self.id = movie.id
        self.imageUrl = ImageRequest(urlPath: movie.posterPath).urlComponents
        self.title = movie.title
        self.originalLanguage = movie.originalLanguage.formatted
        self.genres = movie.genres
            .map { $0.name }
            .joined(separator: ", ")
        self.section = section
    }
}

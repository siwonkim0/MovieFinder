//
//  Section.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/16.
//

import Foundation

struct Section: Hashable {
    let title: String
    let movies: [MovieListCellViewModel]
    
    init(title: String, movies: [MovieListCellViewModel]) {
        self.title = title
        self.movies = movies
    }
}

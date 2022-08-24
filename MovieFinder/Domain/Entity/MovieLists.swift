//
//  MovieLists.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/04.
//

import Foundation

enum MovieLists: CaseIterable, Hashable {
    case nowPlaying
    case popular
    case topRated
    case upComing
    
    var title: String {
        switch self {
        case .nowPlaying:
            return "Now Playing"
        case .popular:
            return "Popular"
        case .topRated:
            return "Top Rated"
        case .upComing:
            return "Upcoming"
        }
    }
}

struct MovieList: Hashable {
    let title: String
    let movies: [MovieListCellViewModel]
}

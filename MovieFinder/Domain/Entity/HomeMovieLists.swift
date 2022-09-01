//
//  HomeMovieLists.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/04.
//

import Foundation

enum HomeMovieLists: CaseIterable {
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
    
    var posterPath: String {
        switch self {
        case .nowPlaying:
            return "movie/now_playing?"
        case .popular:
            return "movie/popular?"
        case .topRated:
            return "movie/top_rated?"
        case .upComing:
            return "movie/upcoming?"
        }
    }
}

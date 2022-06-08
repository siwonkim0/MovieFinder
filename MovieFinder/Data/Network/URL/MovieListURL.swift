//
//  MovieListURL.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/04.
//

import Foundation

enum MovieListURL: CaseIterable {
    static let tmdbApiHost: String = "https://api.themoviedb.org/3/"
    static let omdbApiHost: String = "https://www.omdbapi.com/"
    static let tmdbApiKey: String = "171386c892bc41b9cf77e320a01d6945"
    static let omdbApiKey: String = "c0e72c5d"
    
    case nowPlaying
    case popular
    case topRated
    case upComing
    
    var url: URL? {
        switch self {
        case .nowPlaying:
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/now_playing?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        case .popular:
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/popular?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        case .topRated:
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/top_rated?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        case .upComing:
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/upcoming?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        }
    }
    
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

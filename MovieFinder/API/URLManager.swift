//
//  URLManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import Foundation

enum Language {
    case english
    case korean
    
    var value: String {
        switch self {
        case .english:
            return "en-US"
        case .korean:
            return ""
        }
    }
}

enum URLManager {
    static let apiHost: String = "https://api.themoviedb.org/3/"
    static let apiKey: String = "171386c892bc41b9cf77e320a01d6945"
    static let omdbApiHost: String = "https://www.omdbapi.com/"
    static let omdbApiKey: String = "c0e72c5d"
    
    static func makeURL(with host: String, queryItems: [String: String]) -> URL? {
        var components = URLComponents(string: host)
        queryItems.forEach { (key, value) in
            components?.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        return components?.url
    }
    
    case keyword(language: String, keywords: String)
    case details(id: Int, language: String)
    case omdbDetails(id: String)
    case reviews(id: Int)
    case latest
    case nowPlaying
    case popular
    case topRated
    case upComing
    case image(posterPath: String)
    
    var url: URL? {
        switch self {
        case .keyword(let language, let keywords):
            return URLManager
                .makeURL(with: URLManager.apiHost + "search/movie?",
                         queryItems: ["api_key": URLManager.apiKey,
                                      "language": "\(language)",
                                      "query": "\(keywords)"])
        case .details(let id, let language):
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/" + "\(id)?",
                         queryItems: ["api_key": URLManager.apiKey,
                                      "language": "\(language)"])
        case .omdbDetails(let id):
            return URLManager
                .makeURL(with: URLManager.omdbApiHost + "?\(id)",
                         queryItems: ["i": "\(id)",
                                      "apikey": URLManager.omdbApiKey])
        case .reviews(let id):
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/" + "\(id)" + "/reviews?",
                         queryItems: ["i": "\(id)",
                                      "api_key": URLManager.apiKey])
        case .latest:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/latest",
                         queryItems: ["api_key": URLManager.apiKey])
        case .nowPlaying:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/now_playing",
                         queryItems: ["api_key": URLManager.apiKey])
        case .popular:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/popular",
                         queryItems: ["api_key": URLManager.apiKey])
        case .topRated:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/top_rated",
                         queryItems: ["api_key": URLManager.apiKey])
        case .upComing:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/upcoming",
                         queryItems: ["api_key": URLManager.apiKey])
        case .image(let posterPath):
            return URLManager
                .makeURL(with: "https://image.tmdb.org/t/p/original/" + "\(posterPath)",
                         queryItems: ["api_key": URLManager.apiKey])
        }
    }
}

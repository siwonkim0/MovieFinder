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
    
    case token
    case signUp(token: String)
    case session
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
    case video(id: Int)
    case accountDetail(sessionID: String)
    case rateMovie(sessionID: String, movieID: Int)
    case ratedMovies(sessionID: String, accountID: Int)
    
    var url: URL? {
        switch self {
        case .token:
            return URLManager
                .makeURL(with: URLManager.apiHost + "authentication/token/new?",
                         queryItems: ["api_key": URLManager.apiKey])
        case .signUp(let token):
            return URLManager
                .makeURL(with: "https://www.themoviedb.org/authenticate/" + "\(token)",
                         queryItems: [:])
        case .session:
            return URLManager
                .makeURL(with: URLManager.apiHost + "authentication/session/new?",
                         queryItems: ["api_key": URLManager.apiKey])
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
                .makeURL(with: URLManager.apiHost + "movie/latest?",
                         queryItems: ["api_key": URLManager.apiKey])
        case .nowPlaying:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/now_playing?",
                         queryItems: ["api_key": URLManager.apiKey])
        case .popular:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/popular?",
                         queryItems: ["api_key": URLManager.apiKey])
        case .topRated:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/top_rated?",
                         queryItems: ["api_key": URLManager.apiKey])
        case .upComing:
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/upcoming?",
                         queryItems: ["api_key": URLManager.apiKey])
        case .image(let posterPath):
            return URLManager
                .makeURL(with: "https://image.tmdb.org/t/p/original/" + "\(posterPath)",
                         queryItems: ["api_key": URLManager.apiKey])
        case .video(let id):
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/" + "\(id)" + "/videos?",
                        queryItems: ["api_key": URLManager.apiKey])
        case .accountDetail(let sessionID):
            return URLManager
                .makeURL(with: URLManager.apiHost + "account?",
                        queryItems: ["api_key": URLManager.apiKey,
                                     "session_id": "\(sessionID)"])
        case .rateMovie(let sessionID, let movieID):
            return URLManager
                .makeURL(with: URLManager.apiHost + "movie/" + "\(movieID)" + "/rating?",
                        queryItems: ["api_key": URLManager.apiKey,
                                     "session_id": "\(sessionID)"])
        case .ratedMovies(let sessionID, let accountID):
            return URLManager
                .makeURL(with: URLManager.apiHost + "account/" + "\(accountID)" + "/rated/movies?",
                        queryItems: ["api_key": URLManager.apiKey,
                                     "session_id": "\(sessionID)"])
        }
    }
}

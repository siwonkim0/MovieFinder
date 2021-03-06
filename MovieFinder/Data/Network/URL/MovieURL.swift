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

enum MovieURL {
    static let tmdbApiHost: String = "https://api.themoviedb.org/3/"
    static let omdbApiHost: String = "https://www.omdbapi.com/"
    static let tmdbApiKey: String = "171386c892bc41b9cf77e320a01d6945"
    static let omdbApiKey: String = "c0e72c5d"
    
    case token
    case signUp(token: String)
    case session
    case keyword(language: String, keywords: String)
    case details(id: Int)
    case omdbDetails(id: String)
    case reviews(id: Int)
    case image(posterPath: String)
    case video(id: Int)
    case accountDetail(sessionID: String)
    case rateMovie(sessionID: String, movieID: Int)
    case ratedMovies(sessionID: String, accountID: Int)
    case deleteRating(sessionID: String, movieID: Int)
    case genres
    
    var url: URL? {
        switch self {
        case .token:
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "authentication/token/new?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        case .signUp(let token):
            return URLManager(host: "https://www.themoviedb.org/",
                              rest: "authenticate/\(token)",
                              queryItems: [:]).url
        case .session:
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "authentication/session/new?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        case .image(let posterPath):
            return URLManager(host: "https://image.tmdb.org/t/p/original/",
                              rest: "\(posterPath)",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
            
        case .keyword(let language, let keywords):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "search/movie?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey,
                                           "language": "\(language)",
                                           "query": "\(keywords)"]).url
        case .details(let id):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/\(id)?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        case .omdbDetails(let id):
            return URLManager(host: MovieURL.omdbApiHost,
                              rest: "?\(id)",
                              queryItems: ["i": "\(id)",
                                           "apikey": MovieURL.omdbApiKey]).url
        case .reviews(let id):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/\(id)/reviews?",
                              queryItems: ["i": "\(id)",
                                           "api_key": MovieURL.tmdbApiKey]).url
        case .video(let id):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/\(id)/videos?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey]).url
            
        case .rateMovie(let sessionID, let movieID):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/\(movieID)/rating?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey,
                                           "session_id": "\(sessionID)"]).url
        case .deleteRating(let sessionID, let movieID):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "movie/" + "\(movieID)" + "/rating?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey,
                                           "session_id": "\(sessionID)"]).url
        case .accountDetail(let sessionID):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "account?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey,
                                           "session_id": "\(sessionID)"]).url
        case .ratedMovies(let sessionID, let accountID):
            return URLManager(host: MovieURL.tmdbApiHost,
                              rest: "account/" + "\(accountID)" + "/rated/movies?",
                              queryItems: ["api_key": MovieURL.tmdbApiKey,
                                           "session_id": "\(sessionID)"]).url
        case .genres:
            return URLManager(host: MovieURL.tmdbApiHost, rest: "genre/movie/list?", queryItems: ["api_key": MovieURL.tmdbApiKey]).url
        }
    }
}

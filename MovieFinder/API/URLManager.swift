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
    
    case searchKeywords(language: String, keywords: String)
    case getDetails(id: Int)
    
    var url: URL? {
        switch self {
        case .searchKeywords(let language, let keywords):
            var components = URLComponents(string: URLManager.apiHost + "search/movie?")
            let apiKey = URLQueryItem(name: "api_key", value: URLManager.apiKey)
            let language = URLQueryItem(name: "language", value: "\(language)")
            let keywords = URLQueryItem(name: "query", value: "\(keywords)")
            components?.queryItems = [apiKey, language, keywords]
            return components?.url
        case .getDetails(let id):
            return URL(string: URLManager.apiHost + "movie/?" + URLManager.apiKey + "\(id)")
        }
    }
    
}

//
//  KeywordRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct KeywordRequest: NetworkRequest {
    typealias ResponseType = MovieListDTO
    
    var httpMethod: HttpMethod = .get
    var urlHost: String = MovieURLHost.tmdb.description
    var urlPath: String = "search/movie?"
    var queryParameters: [String: String]
    var httpHeader: [String: String]?
    var httpBody: Data?
}

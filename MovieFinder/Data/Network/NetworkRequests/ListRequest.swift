//
//  NowPlayingRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct ListRequest: NetworkRequest {
    typealias ResponseType = MovieListDTO
    
    var httpMethod: HttpMethod = .get
    var urlHost: String = MovieURLHost.tmdb.description
    var urlPath: String = "movie/now_playing?"
    var queryParameters: [String: String] = ["api_key": ApiKey.tmdb.description]
    var httpHeader: [String: String]?
    var httpBody: Data?
}

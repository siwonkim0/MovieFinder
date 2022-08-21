//
//  RateRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct RateRequest: NetworkRequest {
    typealias ResponseType = RateRespondDTO
    
    var httpMethod: HttpMethod = .post
    var urlHost: String = MovieURLHost.tmdb.description
    var urlPath: String
    var queryParameters: [String: String] = ["api_key": ApiKey.tmdb.description]
    var httpHeader: [String: String]? = ["Content-Type": "application/json"]
    var httpBody: Data?
}

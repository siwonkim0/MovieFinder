//
//  SessionRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct SessionRequest: NetworkRequest {
    typealias ResponseType = Session
    
    var httpMethod: HttpMethod = .post
    var urlHost: String = MovieURLHost.tmdb.description
    var urlPath: String = "authentication/session/new?"
    var queryParameters: [String: String] = ["api_key": ApiKey.tmdb.description]
    var httpHeader: [String: String]? = ["Content-Type": "application/json"]
    var httpBody: Data?
}

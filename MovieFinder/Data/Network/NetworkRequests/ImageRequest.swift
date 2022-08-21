//
//  ImageRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct ImageRequest: NetworkRequest {
    typealias ResponseType = Token
    
    var httpMethod: HttpMethod = .get
    var urlHost: String = MovieURLHost.image.description
    var urlPath: String
    var queryParameters: [String: String] = ["api_key": ApiKey.tmdb.description]
    var httpHeader: [String: String]?
    var httpBody: Data?
}

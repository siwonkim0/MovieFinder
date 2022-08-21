//
//  ReviewsRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct ReviewsRequest: NetworkRequest {
    typealias ResponseType = ReviewListDTO
    
    var httpMethod: HttpMethod = .get
    var urlHost: String = MovieURLHost.tmdb.description
    var urlPath: String //todo: id
    var queryParameters: [String: String] = ["api_key": ApiKey.tmdb.description] //todo: id도 추가해야함
    var httpHeader: [String: String]?
    var httpBody: Data?
}

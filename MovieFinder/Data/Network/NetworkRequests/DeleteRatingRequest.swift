//
//  DeleteRatingRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct DeleteRatingRequest: NetworkRequest {
    typealias ResponseType = RateRespondDTO
    
    var httpMethod: HttpMethod = .delete
    var urlHost: String = MovieURLHost.tmdb.description
    var urlPath: String //todo: 2개
    var queryParameters: [String: String] //todo: 2개
    var httpHeader: [String: String]?
    var httpBody: Data?
}

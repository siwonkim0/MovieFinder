//
//  DetailOmdbMovieInfoRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

struct DetailOmdbMovieInfoRequest: NetworkRequest {
    typealias ResponseType = OMDBMovieDetailDTO
    
    var httpMethod: HttpMethod = .get
    var urlHost: String = MovieURLHost.omdb.description
    var urlPath: String
    var queryParameters: [String: String] = ["api_key": ApiKey.omdb.description] //todo: id도 추가해야함
    var httpHeader: [String: String]?
    var httpBody: Data?
}

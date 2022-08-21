//
//  APIRequest.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

protocol NetworkRequest {
    associatedtype ResponseType: Decodable
    
    var httpMethod: HttpMethod { get }
    var urlHost: String { get }
    var urlPath: String { get }
    var queryParameters: [String: String] { get }
    var httpHeader: [String: String]? { get }
    var httpBody: Data? { get }
}

extension NetworkRequest {
    var urlComponents: URL? {
        var urlComponents = URLComponents(string: self.urlHost + self.urlPath)
        let queries = self.queryParameters.map { URLQueryItem(name: $0, value: $1) }
        urlComponents?.queryItems = queries
        guard let url = urlComponents?.url else {
            return nil
        }
        return url
    }
    
    var urlRequest: URLRequest? {
        guard let urlComponents = urlComponents else {
            return nil
        }
        var request = URLRequest(url: urlComponents)
        request.httpMethod = self.httpMethod.description
        request.allHTTPHeaderFields = httpHeader
        request.httpBody = httpBody
        return request
    }
}

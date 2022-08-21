//
//  URLRequest+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/14.
//

import Foundation

//erase
extension URLRequest {
    init(url: URL, method: HttpMethod) {
        self.init(url: url)

        switch method {
        case .get:
            self.httpMethod = "GET"
        case .post:
            self.httpMethod = "POST"
        case .put:
            self.httpMethod = "PUT"
        case .patch:
            self.httpMethod = "PATCH"
        case .delete:
            self.httpMethod = "DELETE"
        }
    }
    
    enum HttpMethod {
        case get
        case post
        case put
        case patch
        case delete
    }
}

//new
enum HttpMethod {
    case get
    case post
    case put
    case patch
    case delete
    
    var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}

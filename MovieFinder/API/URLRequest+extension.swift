//
//  URLRequest+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/14.
//

import Foundation

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

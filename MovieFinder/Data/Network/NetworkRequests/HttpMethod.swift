//
//  HttpMethod.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/14.
//

import Foundation

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

//
//  URLSessionError.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/14.
//

import Foundation

enum URLSessionError: LocalizedError {
    case invalidRequest
    case requestFailed(description: String)
    case responseFailed(code: Int)
    case invaildData
    case invaildURL
    
    var errorDescription: String {
        switch self {
        case .invalidRequest:
            return "invalidRequest"
        case .requestFailed(description: let description):
            return description
        case .responseFailed(code: let code):
            return "statusCode: \(code)"
        case .invaildData:
            return "invaildData"
        case .invaildURL:
            return "invaildURL"
        }
    }
}

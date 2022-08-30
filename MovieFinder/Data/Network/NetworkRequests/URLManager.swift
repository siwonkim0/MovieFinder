//
//  URLManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/21.
//

import Foundation

struct URLManager {
    let host: String
    let rest: String
    let queryItems: [String: String]
    
    var url: URL? {
        var components = URLComponents(string: host + rest)
        queryItems.forEach { (key, value) in
            components?.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        return components?.url
    }
}

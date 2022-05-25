//
//  RequestToken.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import Foundation
struct RequestToken: Codable {
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case requestToken = "request_token"
    }
}

//
//  Token.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import Foundation

// MARK: - Token
struct Token: Codable {
    let success: Bool
    let expiresAt: String
    let requestToken: String

    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

//
//  Session.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import Foundation

// MARK: - Session
struct Session: Codable {
    let success: Bool
    let sessionID: String?
    let statusCode: Int?
    let statusMessage: String?

    enum CodingKeys: String, CodingKey {
        case success
        case sessionID = "session_id"
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

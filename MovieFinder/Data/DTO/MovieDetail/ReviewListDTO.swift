//
//  Review.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

// MARK: - ReviewListDTO
struct ReviewListDTO: Codable {
    let id: Int
    let page: Int
    let results: [ReviewDTO]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case id
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - ReviewDTO
struct ReviewDTO: Codable {
    let author: String
    let authorDetails: AuthorDetailsDTO
    let content: String
    let createdAt: String
    let id: String
    let updatedAt: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case author
        case authorDetails = "author_details"
        case content
        case createdAt = "created_at"
        case id
        case updatedAt = "updated_at"
        case url
    }
}

// MARK: - AuthorDetailsDTO
struct AuthorDetailsDTO: Codable {
    let name: String
    let username: String
    let avatarPath: String?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case username
        case avatarPath = "avatar_path"
        case rating
    }
}

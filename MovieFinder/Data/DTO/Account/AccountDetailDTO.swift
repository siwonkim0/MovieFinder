//
//  AccountDetail.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

// MARK: - AccountDetailDTO
struct AccountDetailDTO: Codable {
    let avatar: AvatarDTO
    let id: Int
    let iso639_1: String
    let iso3166_1: String
    let name: String
    let includeAdult: Bool
    let username: String

    enum CodingKeys: String, CodingKey {
        case avatar, id
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name
        case includeAdult = "include_adult"
        case username
    }
}

// MARK: - AvatarDTO
struct AvatarDTO: Codable {
    let gravatar: GravatarDTO
    let tmdb: TmdbDTO
}

// MARK: - GravatarDTO
struct GravatarDTO: Codable {
    let hash: String
}

// MARK: - TmdbDTO
struct TmdbDTO: Codable {
    let avatarPath: String?

    enum CodingKeys: String, CodingKey {
        case avatarPath = "avatar_path"
    }
}

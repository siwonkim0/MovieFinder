//
//  VideoList.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import Foundation

// MARK: - VideoListDTO
struct VideoListDTO: Decodable {
    let id: Int?
    let results: [VideoDTO]?
}

// MARK: - VideoDTO
struct VideoDTO: Decodable {
    let iso639_1: String?
    let iso3166_1: String?
    let name: String?
    let key: String?
    let publishedAt: String?
    let site: String?
    let size: Int?
    let type: String?
    let isOfficial: Bool?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name
        case key
        case publishedAt = "published_at"
        case site
        case size
        case type
        case isOfficial = "official"
        case id
    }
}

//
//  Genres.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/03.
//

import Foundation

// MARK: - Genres
struct GenresDTO: Codable {
    let genres: [Genre]
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

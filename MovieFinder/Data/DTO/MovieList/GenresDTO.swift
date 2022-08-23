//
//  Genres.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/03.
//

import Foundation

// MARK: - Genres
struct GenresDTO: Codable, Hashable {
    let genres: [Genre]
}

// MARK: - Genre
struct Genre: Codable, Hashable {
    let id: Int
    let name: String
}

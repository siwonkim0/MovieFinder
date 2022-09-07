//
//  MovieDetailBasicInfo.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/20.
//

import Foundation

struct MovieDetailBasicInfo: Hashable {
    let id: Int
    let imdbID: String
    let rating: Double
    let posterPath: String
    let title: String
    let genre: String
    let year: String
    let runtime: String
    let plot: String
    let actors: String
}

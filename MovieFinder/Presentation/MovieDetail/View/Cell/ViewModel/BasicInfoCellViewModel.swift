//
//  BasicInfoCellViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/09/07.
//

import Foundation

struct BasicInfoCellViewModel: Identifiable, Equatable {
    let id: Int
    let averageRating: String
    let url: URL?
    let title: String
    let description: String
    let myRating: Double
    
    init(movie: MovieDetailBasicInfo, myRating: Double) {
        self.id = movie.id
        self.averageRating = "⭐ " + String(movie.rating * 0.5)
        self.url = ImageRequest(urlPath: "\(movie.posterPath)").urlComponents
        self.title = movie.title
        self.description = [
            movie.year,
            movie.genre,
            movie.runtime
        ].joined(separator: " • ")
        self.myRating = myRating
    }

}

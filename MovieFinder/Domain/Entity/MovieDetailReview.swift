//
//  MovieDetailReview.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/20.
//

import Foundation

struct MovieDetailReview: Identifiable, Hashable {
    let id: UUID = UUID()
    let username: String
    let rating: Double
    var content: String
    var contentOriginal: String
    var contentPreview: String
    let createdAt: String
    var showAllContent: Bool = false
}

//
//  MovieDetailReview.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/20.
//

import Foundation

struct MovieDetailReview: Hashable {
    let id: UUID = UUID()
    let username: String
    let rating: Double
    let content: String
    let createdAt: String
    var showAllContent: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieDetailReview, rhs: MovieDetailReview) -> Bool {
        lhs.id == rhs.id
    }
}

//
//  Section.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/16.
//

import Foundation

final class Section: Hashable {
    private let id = UUID()
    let title: String
    let movies: [MovieListCellViewModel]
    
    init(title: String, movies: [MovieListCellViewModel]) {
        self.title = title
        self.movies = movies
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }
}

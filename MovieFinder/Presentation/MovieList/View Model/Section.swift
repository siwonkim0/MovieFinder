//
//  Section.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/16.
//

import Foundation

final class Section: Hashable {
    var id = UUID()
    var title: String
    var movies: [MovieListItemViewModel]
    
    init(title: String, movies: [MovieListItemViewModel]) {
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

//
//  MovieList.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

struct MovieList: Hashable {
    let page: Int
    let items: [MovieListItem]
    let totalPages: Int
    var section: HomeMovieLists? = nil
    
    var nextPage: Int? {
        let nextPage = self.page + 1
        guard nextPage < self.totalPages else {
            return nil
        }
        return nextPage
    }
}

struct MovieListItem: Hashable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String
    let originalLanguage: OriginalLanguage
    let genres: [Genre]
}

enum OriginalLanguage: String {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"
    case french = "fr"
    case latin = "la"
    case hindi = "hi"
    case japanese = "ja"
    case korean = "ko"
    case thai = "th"
    
    init?(rawValue: String) {
        switch rawValue {
        case "en":
            self = .english
        case "tr":
            self = .turkish
        case "es":
            self = .spanish
        case "fr":
            self = .french
        case "la":
            self = .latin
        case "hi":
            self = .hindi
        case "ja":
            self = .japanese
        case "ko":
            self = .korean
        case "th":
            self = .thai
        default:
            return nil
        }
    }
    
    var formatted: String {
        switch self {
        case .english:
            return "ENGLISH"
        case .turkish:
            return "TURKISH"
        case .spanish:
            return "SPANISH"
        case .french:
            return "FRENCH"
        case .latin:
            return "LATIN"
        case .hindi:
            return "HINDI"
        case .japanese:
            return "JAPANESE"
        case .korean:
            return "KOREAN"
        case .thai:
            return "THAI"
        }
    }
}
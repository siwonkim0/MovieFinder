//
//  MovieURLHost.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

enum MovieURLHost {
    case tmdb
    case tmdbSignUp
    case omdb
    case image
    
    var description: String {
        switch self {
        case .tmdb:
            return "https://api.themoviedb.org/3/"
        case .tmdbSignUp:
            return "https://www.themoviedb.org/"
        case .omdb:
            return "https://www.omdbapi.com/"
        case .image:
            return "https://image.tmdb.org/t/p/original/"
        }
    }
}

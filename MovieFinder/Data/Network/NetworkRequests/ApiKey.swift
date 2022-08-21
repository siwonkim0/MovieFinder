//
//  ApiKey.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/21.
//

import Foundation

enum ApiKey {
    case tmdb
    case omdb
    
    var description: String {
        switch self {
        case .tmdb:
            return "171386c892bc41b9cf77e320a01d6945"
        case .omdb:
            return "c0e72c5d"
        }
    }
}

//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesUseCase {
    func getMovieListItem(from url: URL?) async throws -> [MovieListItem]
}

class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    //entity -> Model 변경
    func getMovieListItem(from url: URL?) async throws -> [MovieListItem] {
        let moviesResult = try await moviesRepository.getMovieListItem(from: url)
        return moviesResult
    }
}

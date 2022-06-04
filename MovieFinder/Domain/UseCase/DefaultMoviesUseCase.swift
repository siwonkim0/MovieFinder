//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesUseCase {
    func getNowPlaying(completion: @escaping (Result<[MovieListItem], Error>) -> Void)
}

class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    //entity -> Model 변경
    func getNowPlaying(completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        moviesRepository.getNowPlayingWithGenres { result in
            if case .success(let moviesResult) = result {
                print(moviesResult[1].genres)
                completion(.success(moviesResult))
            }
        }
    }
}

//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesRepository {
    func getNowPlaying(completion: @escaping (Result<[MovieListItem], Error>) -> Void)
}

class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func getNowPlaying(completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        let url = MovieURL.nowPlaying.url
        apiManager.getData(from: url, format: MovieList.self) { result in
            switch result {
            case .success(let movieList):
                completion(.success(movieList.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

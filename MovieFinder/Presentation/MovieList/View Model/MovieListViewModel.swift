//
//  MovieListViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MovieListViewModel {
    let defaultMoviesUseCase: MoviesUseCase
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func getNowPlaying(completion: @escaping (Result<String, Error>) -> Void) {
        defaultMoviesUseCase.getNowPlaying { result in
            switch result {
            case .success(let items):
                print(items[0].title)
                completion(.success(items[0].posterPath!))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getPopular() {
        let url = MovieURL.popular.url
        APIManager.shared.getData(from: url, format: MovieList.self) { result in
            switch result {
            case .success(let movieList):
                movieList.results.forEach {
                    print($0.originalTitle)
                }
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getTopRated() {
        let url = MovieURL.topRated.url
        APIManager.shared.getData(from: url, format: MovieList.self) { result in
            switch result {
            case .success(let movieList):
                movieList.results.forEach {
                    print($0.originalTitle)
                }
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getUpcoming() {
        let url = MovieURL.upComing.url
        APIManager.shared.getData(from: url, format: MovieList.self) { result in
            switch result {
            case .success(let movieList):
                movieList.results.forEach {
                    print($0.originalTitle)
                }
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
    }
}

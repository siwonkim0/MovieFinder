//
//  MovieListCollectionViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/02.
//

import Foundation
class MovieListCollectionViewModel {
    var itemViewModels: [MovieListCollectionViewItemViewModel] = []
    let defaultMoviesUseCase: MoviesUseCase
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func getNowPlaying(completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        defaultMoviesUseCase.getNowPlaying { result in
            switch result {
            case .success(let items):
                self.itemViewModels = items.map { item in
                    MovieListCollectionViewItemViewModel(movie: item)
                }
                completion(.success(items))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getPopular() {
        let url = MovieURL.popular.url
        APIManager.shared.getData(from: url, format: MovieListDTO.self) { result in
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
        APIManager.shared.getData(from: url, format: MovieListDTO.self) { result in
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
        APIManager.shared.getData(from: url, format: MovieListDTO.self) { result in
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

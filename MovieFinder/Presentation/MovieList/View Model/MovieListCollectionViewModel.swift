//
//  MovieListCollectionViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/02.
//

import Foundation
class MovieListCollectionViewModel {
    let collectionType: MovieListURL
    var itemViewModels: [MovieListCollectionViewItemViewModel] = []
    let defaultMoviesUseCase: MoviesUseCase
    
    init(collectionType: MovieListURL, defaultMoviesUseCase: MoviesUseCase) {
        self.collectionType = collectionType
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func getMovieListItem(completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        defaultMoviesUseCase.getMovieListItem(from: collectionType.url) { result in
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
}

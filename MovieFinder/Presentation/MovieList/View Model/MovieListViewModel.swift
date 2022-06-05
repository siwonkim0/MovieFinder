//
//  MovieListViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MovieListViewModel {
    let defaultMoviesUseCase: MoviesUseCase
    let collectionTypes: [MovieListURL] = MovieListURL.allCases
    var collectionViewModels: [MovieListCollectionViewModel] = []
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
        createCollectionViewModels()
    }
    
    func createCollectionViewModels() {
        collectionTypes.forEach { collectionType in
            collectionViewModels.append(MovieListCollectionViewModel(collectionType: collectionType, defaultMoviesUseCase: defaultMoviesUseCase))
        }
        
    }

}

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
    
    func getMovieListItem() async {
        do {
            let items = try await defaultMoviesUseCase.getMovieListItem(from: collectionType.url)
            self.itemViewModels = items.map { item in
                MovieListCollectionViewItemViewModel(movie: item)
            }
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
}

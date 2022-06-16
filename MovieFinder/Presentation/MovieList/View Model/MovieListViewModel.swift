//
//  MovieListViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift

final class MovieListViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let movieItems: Observable<[MovieListCollectionViewItemViewModel]>
    }
    
    let defaultMoviesUseCase: MoviesUseCase
    let collectionTypes: [MovieListURL] = MovieListURL.allCases
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let viewWillAppearObservable = input.viewWillAppear
            .flatMap {
                self.fetchData(from: self.collectionTypes[0].url!)
            }
        return Output(movieItems: viewWillAppearObservable)
    }
    
    func fetchData(from collectionTypeUrl: URL) -> Observable<[MovieListCollectionViewItemViewModel]> {
        return defaultMoviesUseCase.getMovieListItem(from: collectionTypeUrl)
            .map { items in
                return items.map { item in
                    MovieListCollectionViewItemViewModel(movie: item)
                }
            }
    }

}

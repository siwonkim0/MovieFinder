//
//  MovieListCollectionViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/02.
//

import Foundation
import RxSwift
import RxRelay

class MovieListCollectionViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let movieItems: Observable<[MovieListCollectionViewItemViewModel]>
    }
    
    let collectionType: MovieListURL
//    var itemViewModels = BehaviorSubject<[MovieListCollectionViewItemViewModel]>(value: [])
    let defaultMoviesUseCase: MoviesUseCase
    
    init(collectionType: MovieListURL, defaultMoviesUseCase: MoviesUseCase) {
        self.collectionType = collectionType
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let viewWillAppearObservable = input.viewWillAppear
            .flatMap { self.fetchData() }
        return Output(movieItems: viewWillAppearObservable)
    }
    
    func fetchData() -> Observable<[MovieListCollectionViewItemViewModel]> {
        let items = defaultMoviesUseCase.getMovieListItem(from: collectionType.url)
        
        return items
            .map { items in
                var itemViewModels = [MovieListCollectionViewItemViewModel]()
                items.forEach { item in
                    itemViewModels.append(MovieListCollectionViewItemViewModel(movie: item))
                }
//                self.itemViewModels.onNext(itemViewModels)
                return itemViewModels
            }
    }
}

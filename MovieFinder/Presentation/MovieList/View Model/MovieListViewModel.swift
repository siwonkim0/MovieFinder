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
        let refresh: Observable<Void>
    }
    
    struct Output {
        let sectionObservable: Observable<[Section]>
        let refresh: Observable<[Section]>
    }
    
    let defaultMoviesUseCase: MoviesUseCase
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let sectionObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) in
                self.getMovieLists()
            }
        let refreshObservable = input.refresh
            .withUnretained(self)
            .flatMap { (self, _) in
                self.getMovieLists()
            }

        return Output(sectionObservable: sectionObservable, refresh: refreshObservable)
    }
    
    private func getMovieLists() -> Observable<[Section]> {
        self.defaultMoviesUseCase.getMovieLists()
            .map { items in
                items.map { lists in
                    lists.map { item in
                        MovieListCellViewModel(movie: item, section: item.section!)
                    }
                }
            }
            .map { items in
                return items.map { items -> Section in
                    let title = items.map({$0.section.title}).first ?? ""
                    return Section(title: title, movies: items)
                }
            }
    }
    
}

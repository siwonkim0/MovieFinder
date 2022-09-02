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
        let section: Observable<[Section]>
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

        return Output(section: sectionObservable, refresh: refreshObservable)
    }
    
    private func getMovieLists() -> Observable<[Section]> {
        self.defaultMoviesUseCase.getMovieLists()
            .map { lists in
                lists.map { list in
                    list.items.map { movie in
                        MovieListCellViewModel(movie: movie, section: list.section!)
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

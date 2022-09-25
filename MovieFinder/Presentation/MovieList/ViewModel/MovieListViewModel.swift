//
//  MovieListViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MovieListViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let section: Driver<[Section]>
        let refresh: Signal<[Section]>
    }
    
    private let defaultMoviesUseCase: MoviesUseCase
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let sectionObservable = input.viewWillAppear
            .take(1)
            .flatMap { _ -> Observable<[Section]> in
                return self.getMovieLists()
            }
            .asDriver(onErrorJustReturn: [])
        
        let refreshObservable = input.refresh
            .withUnretained(self)
            .flatMap { _ in
                self.getMovieLists()
            }
            .asSignal(onErrorJustReturn: [])

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

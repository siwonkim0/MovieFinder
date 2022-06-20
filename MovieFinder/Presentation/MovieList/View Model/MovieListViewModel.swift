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
    
    private let sectionUrls: [MovieListURL] = MovieListURL.allCases
    let defaultMoviesUseCase: MoviesUseCase
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let sectionObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) in
                self.fetchAllSections()
            }
        let refreshObservable = input.refresh
            .withUnretained(self)
            .flatMap { (self, _) in
                self.fetchAllSections()
            }

        return Output(sectionObservable: sectionObservable, refresh: refreshObservable)
    }
    
    private func fetchData(from sectionType: MovieListURL) -> Observable<Section> {
        return defaultMoviesUseCase.getMovieListItem(from: sectionType)
            .map { items in
                return items.map { item in
                    MovieListItemViewModel(movie: item, section: sectionType)
                }
            }
            .map { items in
                Section(title: sectionType.title, movies: items)
            }
    }
    
    private func fetchAllSections() -> Observable<[Section]> {
        let sections = sectionUrls.map { movieListUrl in
            fetchData(from: movieListUrl)
        }
        return Observable.zip(sections) { $0 }
    }
    
}

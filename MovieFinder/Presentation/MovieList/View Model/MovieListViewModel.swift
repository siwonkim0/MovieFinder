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
        let sectionObservable: Observable<[Section]>
    }
    
    private let sectionUrls: [MovieListURL] = MovieListURL.allCases
    let defaultMoviesUseCase: MoviesUseCase
    
    init(defaultMoviesUseCase: MoviesUseCase) {
        self.defaultMoviesUseCase = defaultMoviesUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let sectionObservable = input.viewWillAppear
            .flatMap {
                self.fetchAllSections()
            }

        return Output(sectionObservable: sectionObservable)
    }
    
    private func fetchData(from sectionType: MovieListURL) -> Observable<Section> {
        return defaultMoviesUseCase.getMovieListItem(from: sectionType.url)
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

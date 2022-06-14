//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesUseCase {
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]>
}

class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]> {
        return moviesRepository.getMovieListItem(from: url)
    }
}

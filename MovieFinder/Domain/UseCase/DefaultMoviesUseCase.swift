//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesUseCase {
    func getMovieListItem(from listUrl: MovieListURL) -> Observable<[MovieListItem]>
}

class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func getMovieListItem(from listUrl: MovieListURL) -> Observable<[MovieListItem]> {
        let url = listUrl.url
        return moviesRepository.getMovieListItem(from: url)
    }
}

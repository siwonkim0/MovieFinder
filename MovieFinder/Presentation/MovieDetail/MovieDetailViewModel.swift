//
//  MovieDetailViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MovieDetailViewModel {
    private let movieID: Int
    private let useCase: DefaultMoviesUseCase
    
    init(movieID: Int, useCase: DefaultMoviesUseCase) {
        self.movieID = movieID
        self.useCase = useCase
    }
    
    func getBasicDetails() {
        let movieDetailItem = useCase.getMovieDetailItem(from: movieID)
        movieDetailItem.subscribe(onNext: { detail in
            print(detail)
        })
    }
    
}

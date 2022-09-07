//
//  BasicInfoCellViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/09/07.
//

import Foundation

struct BasicInfoCellViewModel: Identifiable {
    let id: Int
    let averageRating: String
    let url: URL?
    let title: String
    let description: String
    
    init(movie: MovieDetailBasicInfo) {
        self.id = movie.id
        self.averageRating = "⭐ " + String(movie.rating * 0.5)
        self.url = ImageRequest(urlPath: "\(movie.posterPath)").urlComponents
        self.title = movie.title
        self.description = [
            movie.year,
            movie.genre,
            movie.runtime
        ].joined(separator: " • ")
    }

    //        let myRating = input.viewWillAppear
    //            .withUnretained(self)
    //            .flatMap { (self, _) -> Observable<Double> in
    //                return self.accountUseCase.getMovieRating(of: self.movieID)
    //            }
    //            .asDriver(onErrorJustReturn: 0)
    //
    //        let updateRating = input.tapRatingButton
    //            .skip(1)
    //            .withUnretained(self)
    //            .flatMapLatest { (self, rating) -> Observable<Bool> in
    //                return self.accountUseCase.updateMovieRating(of: self.movieID, to: rating)
    //            }
    //            .asDriver(onErrorJustReturn: false)
}

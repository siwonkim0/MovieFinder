//
//  MovieDetailViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MovieDetailViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let tapRatingButton: Observable<Double>
    }
    
    struct Output {
        let imageUrl: Driver<URL>
        let title: Driver<String>
        let description: Driver<String>
        let averageRating: Driver<String>
        let plot: Driver<String>
        let reviews: Driver<[MovieDetailReview]>
        let myRating: Driver<Double>
        let updateRating: Driver<Bool>
    }
    
    private let movieID: Int
    private let moviesUseCase: MoviesUseCase
    private let accountUseCase: MoviesAccountUseCase
    var reviews: [MovieDetailReview]?
    
    init(movieID: Int, moviesUseCase: MoviesUseCase, accountUseCase: MoviesAccountUseCase) {
        self.movieID = movieID
        self.moviesUseCase = moviesUseCase
        self.accountUseCase = accountUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let reviews = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) -> Observable<[MovieDetailReview]> in
                return self.moviesUseCase.getMovieDetailReviews(with: self.movieID)
                    .withUnretained(self)
                    .map { (self, reviews) -> [MovieDetailReview] in
                        self.reviews = reviews
                        return reviews
                    }
            }.asDriver(onErrorJustReturn: [
                MovieDetailReview(
                    userName: "N/A",
                    rating: 0,
                    content: "N/A",
                    contentOriginal: "N/A",
                    contentPreview: "N/A",
                    createdAt: "N/A"
                )])
        
        let basicInfo = input.viewWillAppear
            .withUnretained(self)
            .flatMapLatest { (self, _) in
                self.moviesUseCase.getMovieDetail(with: self.movieID)
            }
            .take(1)
            .asDriver(onErrorJustReturn: MovieDetailBasicInfo(
                id: 0,
                imdbID: "N/A",
                rating: 0,
                posterPath: "N/A",
                title: "N/A",
                genre: "N/A",
                year: "N/A",
                runtime: "N/A",
                plot: "N/A",
                actors: "N/A"
            ))
        
        let imageUrl = basicInfo
            .map { basicInfo -> URL in
            guard let posterPath = basicInfo.posterPath,
                  let url = ImageRequest(urlPath: "\(posterPath)").urlComponents else {
                return URL(string: "")!
            }
            return url
        }
        
        let title = basicInfo
            .map { $0.title }
        
        let description = basicInfo
            .map { [$0.year, $0.genre, $0.runtime].joined(separator: " • ") }
        
        let averageRating = basicInfo
            .map { "⭐ " + String($0.rating * 0.5) }
        
        let plot = basicInfo
            .map { $0.plot }
        
        let myRating = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) -> Observable<Double> in
                return self.accountUseCase.getMovieRating(of: self.movieID)
            }
            .asDriver(onErrorJustReturn: 0)
        
        let updateRating = input.tapRatingButton
            .skip(1)
            .withUnretained(self)
            .flatMapLatest { (self, rating) -> Observable<Bool> in
                return self.accountUseCase.updateMovieRating(of: self.movieID, to: rating)
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            imageUrl: imageUrl,
            title: title,
            description: description,
            averageRating: averageRating,
            plot: plot,
            reviews: reviews,
            myRating: myRating,
            updateRating: updateRating
        )
    }
    
    func toggle(with reviewID: MovieDetailReview.ID) {
        guard var selectedReview = reviews?.filter({ $0.id == reviewID }).first else {
            return
        }
        selectedReview.showAllContent.toggle()
        if let index = reviews?.firstIndex(where: { $0.id == reviewID }) {
            reviews?[index] = selectedReview
        }
    }
    
    func updateReviewState(with reviewID: MovieDetailReview.ID) {
        guard var selectedReview = reviews?.filter({ $0.id == reviewID }).first else {
            return
        }
        if selectedReview.showAllContent {
            selectedReview.content = selectedReview.contentOriginal
        } else {
            selectedReview.content = selectedReview.contentPreview
        }
        if let index = reviews?.firstIndex(where: { $0.id == reviewID }) {
            reviews?[index] = selectedReview
        }
    }
    
}

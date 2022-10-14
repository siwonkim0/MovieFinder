//
//  MovieDetailReactor.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/10/12.
//

import Foundation
import ReactorKit

class MovieDetailReactor: Reactor {
    var initialState: State = State()
    private let movieID: Int
    private let moviesUseCase: MoviesUseCase
    private let accountUseCase: MoviesAccountUseCase
    
    init(movieID: Int, moviesUseCase: MoviesUseCase, accountUseCase: MoviesAccountUseCase) {
        self.movieID = movieID
        self.moviesUseCase = moviesUseCase
        self.accountUseCase = accountUseCase
    }
    
    enum Action {
        case setInitialData
        case rate(RatedMovie)
        case setReviewState(MovieDetailReview.ID?)
    }
    
    enum Mutation {
        case fetchMovieDetailBasicInfos(BasicInfoCellViewModel)
        case fetchReviews([MovieDetailReview])
        case updateRating(RatedMovie)
        case updateReviewContents(MovieDetailReview.ID?)
        case updateSelectedReviewID(MovieDetailReview.ID?)
    }
    
    struct State {
        var basicInfos: BasicInfoCellViewModel?
        var reviews: [MovieDetailReview]?
        @Pulse var rating: Double?
        @Pulse var selectedReviewID: UUID?
    }
    
    //API 호출같은 사이드 이펙트 수행
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setInitialData:
            return Observable.concat([
                getMovieDetailBasicInfos()
                    .map { Mutation.fetchMovieDetailBasicInfos($0) },
                getMovieDetailReviews()
                    .map { Mutation.fetchReviews($0) }
            ])
        case let .rate(ratedMovie):
            return accountUseCase.updateMovieRating(of: ratedMovie.movieId, to: ratedMovie.rating)
                .map { Mutation.updateRating($0) }
        case let .setReviewState(selectedReviewID):
            return Observable.concat([
                Observable.just(Mutation.updateSelectedReviewID(selectedReviewID)),
                Observable.just(Mutation.updateReviewContents(selectedReviewID))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .fetchMovieDetailBasicInfos(results):
            var newState = state
            newState.basicInfos = results
            return newState
        case let .fetchReviews(reviews):
            var newState = state
            newState.reviews = reviews
            return newState
        case let .updateReviewContents(reviewID):
            var newState = state
            guard let reviews = state.reviews,
                  let reviewID = reviewID else {
                return newState
            }
            let newReviews = updateReviewState(currentReviews: reviews, with: reviewID)
            newState.reviews = newReviews
            return newState
        case let .updateRating(movie):
            var newState = state
            newState.rating = movie.rating
            return newState
        case let .updateSelectedReviewID(reviewID):
            var newState = state
            newState.selectedReviewID = reviewID
            return newState
        }
    }
    
    private func getMovieDetailBasicInfos() -> Observable<BasicInfoCellViewModel> {
        let detail = moviesUseCase.getMovieDetail(with: movieID)
        let myRating = accountUseCase.getMovieRating(of: movieID)
        return Observable.zip(detail, myRating)
            .map { detail, myRating in
                let basicInfo = BasicInfoCellViewModel(movie: detail, myRating: myRating)
                return basicInfo
            }
    }
    
    private func getMovieDetailReviews() -> Observable<[MovieDetailReview]> {
        return moviesUseCase.getMovieDetailReviews(with: self.movieID)
            .map { reviews -> [MovieDetailReview] in
                return reviews
            }
    }
    
    private func updateReviewState(currentReviews: [MovieDetailReview], with reviewID: MovieDetailReview.ID) -> [MovieDetailReview] {
        var newReviews = currentReviews
        guard var selectedReview = newReviews.filter({ $0.id == reviewID }).first else {
            return newReviews
        }
        selectedReview.showAllContent.toggle()
        
        if selectedReview.showAllContent {
            selectedReview.content = selectedReview.contentOriginal
        } else {
            selectedReview.content = selectedReview.contentPreview
        }
        if let index = newReviews.firstIndex(where: { $0.id == reviewID }) {
            newReviews[index] = selectedReview
        }
        return newReviews
    }
}

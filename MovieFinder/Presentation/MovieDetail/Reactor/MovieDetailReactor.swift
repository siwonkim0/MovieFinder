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
                getMovieDetailBasicInfosMutation(),
                getMovieDetailReviewsMutation()
            ])
        case let .rate(ratedMovie):
            return updateMovieRatingMutation(of: ratedMovie)
        case let .setReviewState(selectedReviewID):
            return Observable.concat([
                Observable.just(Mutation.updateSelectedReviewID(selectedReviewID)),
                Observable.just(Mutation.updateReviewContents(selectedReviewID))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .fetchMovieDetailBasicInfos(results):
            newState.basicInfos = results
            return newState
        case let .fetchReviews(reviews):
            newState.reviews = reviews
            return newState
        case let .updateReviewContents(reviewID):
            guard let reviews = state.reviews,
                  let reviewID = reviewID else {
                return newState
            }
            let newReviews = updateReviewState(currentReviews: reviews, with: reviewID)
            newState.reviews = newReviews
            return newState
        case let .updateRating(movie):
            newState.rating = movie.rating
            return newState
        case let .updateSelectedReviewID(reviewID):
            newState.selectedReviewID = reviewID
            return newState
        }
    }
    
    private func getMovieDetailBasicInfosMutation() -> Observable<Mutation> {
        let detail = moviesUseCase.getMovieDetail(with: movieID)
        let myRating = accountUseCase.getMovieRating(of: movieID)
        return Observable.zip(detail, myRating)
            .flatMap { detail, myRating -> Observable<Mutation> in
                let basicInfo = BasicInfoCellViewModel(movie: detail, myRating: myRating)
                return .just(.fetchMovieDetailBasicInfos(basicInfo))
            }
    }
    
    private func getMovieDetailReviewsMutation() -> Observable<Mutation> {
        return moviesUseCase.getMovieDetailReviews(with: self.movieID)
            .flatMap { reviews -> Observable<Mutation> in
                return .just(.fetchReviews(reviews))
            }
    }
    
    private func updateMovieRatingMutation(of ratedMovie: RatedMovie) -> Observable<Mutation> {
        return accountUseCase.updateMovieRating(of: ratedMovie.movieId, to: ratedMovie.rating)
            .map { Mutation.updateRating($0) }
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

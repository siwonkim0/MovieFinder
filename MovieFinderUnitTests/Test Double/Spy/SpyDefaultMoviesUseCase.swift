//
//  SpyDefaultMoviesUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SpyDefaultMoviesUseCase: MoviesUseCase {
    private var getMovieListsCallCount: Int = 0
    private var getSearchResultsCallCount: Int = 0
    private var getMovieDetailCallCount: Int = 0
    private var getMovieDetailReviewsCallCount: Int = 0
    
    func getMovieLists() -> Observable<[MovieList]> {
        getMovieListsCallCount += 1
        let movieLists = [
            MovieList(
                page: 1,
                items: [
                    MovieListItem(
                        id: 1,
                        title: "s",
                        overview: "",
                        releaseDate: "",
                        posterPath: "",
                        originalLanguage: OriginalLanguage(rawValue: "en")!,
                        genres: [Genre(id: 1, name: "")],
                        rating: 0
                    ),
                    MovieListItem(
                        id: 1,
                        title: "s",
                        overview: "",
                        releaseDate: "",
                        posterPath: "",
                        originalLanguage: OriginalLanguage(rawValue: "en")!,
                        genres: [Genre(id: 1, name: "")],
                        rating: 0
                    )],
                totalPages: 1,
                section: .nowPlaying
            ),
            MovieList(
                page: 1,
                items: [
                    MovieListItem(
                        id: 1,
                        title: "",
                        overview: "",
                        releaseDate: "",
                        posterPath: "",
                        originalLanguage: OriginalLanguage(rawValue: "en")!,
                        genres: [Genre(id: 1, name: "")],
                        rating: 0
                    )],
                totalPages: 1,
                section: .upComing
            ),
            MovieList(
                page: 1,
                items: [
                    MovieListItem(
                        id: 1,
                        title: "",
                        overview: "",
                        releaseDate: "",
                        posterPath: "",
                        originalLanguage: OriginalLanguage(rawValue: "en")!,
                        genres: [Genre(id: 1, name: "")],
                        rating: 0
                    )],
                totalPages: 1,
                section: .topRated
            ),
            MovieList(
                page: 1,
                items: [
                    MovieListItem(
                        id: 1,
                        title: "",
                        overview: "",
                        releaseDate: "",
                        posterPath: "",
                        originalLanguage: OriginalLanguage(rawValue: "en")!,
                        genres: [Genre(id: 1, name: "")],
                        rating: 0
                    )],
                totalPages: 1,
                section: .popular
            )]
        
        return Observable.just(movieLists)
    }
    
    func getSearchResults(with keyword: String, page: Int) -> Observable<MovieList> {
        getSearchResultsCallCount += 1
        let movieLists = MovieList(
            page: 1,
            items: [
                MovieListItem(
                    id: 1,
                    title: "",
                    overview: "",
                    releaseDate: "",
                    posterPath: "",
                    originalLanguage: OriginalLanguage(rawValue: "")!,
                    genres: [Genre(id: 1, name: "")],
                    rating: 0
                )],
            totalPages: 1
        )
        return Observable.just(movieLists)
    }
    
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo> {
        getMovieDetailCallCount += 1
        let movieDetail = MovieDetailBasicInfo(
            id: -1, //test
            imdbID: "id",
            rating: 1.0,
            posterPath: "posterPath",
            title: "title",
            genre: "genre",
            year: "year",
            runtime: "runtime",
            plot: "plot",
            actors: "actors"
        )
        return Observable.just(movieDetail)
    }
    
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieDetailReview]> {
        getMovieDetailReviewsCallCount += 1
        let reviews = [
        MovieDetailReview(
            userName: "",
            rating: 1.0,
            content: "",
            contentOriginal: "",
            contentPreview: "",
            createdAt: ""
        )]
        return Observable.just(reviews)
    }
    
    func verifyGetMovieLists(callCount: Int) {
        XCTAssertEqual(getMovieListsCallCount, callCount)
    }
    
    func verifyGetMovieDetailReviews(callCount: Int) {
        XCTAssertEqual(getMovieDetailReviewsCallCount, callCount)
    }
    
    func verifyGetMovieDetail(callCount: Int) {
        XCTAssertEqual(getMovieDetailCallCount, callCount)
    }
    
    
}

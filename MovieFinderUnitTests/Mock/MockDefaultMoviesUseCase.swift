//
//  MockDefaultMoviesUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import Foundation
@testable import MovieFinder

import RxSwift
import XCTest

final class MockDefaultMoviesUseCase: MoviesUseCase {
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
                        genres: [Genre(id: 1, name: "")]
                    ),
                    MovieListItem(
                        id: 1,
                        title: "s",
                        overview: "",
                        releaseDate: "",
                        posterPath: "",
                        originalLanguage: OriginalLanguage(rawValue: "en")!,
                        genres: [Genre(id: 1, name: "")]
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
                        genres: [Genre(id: 1, name: "")]
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
                        genres: [Genre(id: 1, name: "")]
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
                        genres: [Genre(id: 1, name: "")]
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
                    genres: [Genre(id: 1, name: "")]
                )],
            totalPages: 1
        )
        return Observable.just(movieLists)
    }
    
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo> {
        getMovieDetailCallCount += 1
        let movieDetail = MovieDetailBasicInfo(
            id: 1,
            imdbID: "",
            rating: 1.0,
            posterPath: "",
            title: "",
            genre: "",
            year: "",
            runtime: "",
            plot: "",
            actors: ""
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
    
    func verifygetMovieListsCallCount() {
        XCTAssertEqual(getMovieListsCallCount, 1)
    }
    
    
}

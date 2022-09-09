//
//  SpyDefaultMoviesRepository.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SpyDefaultMoviesRepository: MoviesRepository {
    private var getMovieListCallCount: Int = 0
    private var getGenresListCallCount: Int = 0
    private var getSearchResultListCallCount: Int = 0
    private var getOmdbMovieDetailCallCount: Int = 0
    private var getTmdbMovieDetailtCallCount: Int = 0
    private var getMovieDetailReviewsCallCount: Int = 0
    
    func getMovieList(with path: String) -> Observable<MovieListDTO> {
        getMovieListCallCount += 1
        
        let movieListDTO = MovieListDTO(
            dates: DatesDTO(maximum: "", minimum: ""),
            page: 1,
            results: [MovieListItemDTO(
                adult: false,
                backdropPath: "",
                genreIDS: [0],
                id: 1,
                originalLanguage: "",
                originalTitle: "",
                overview: "",
                popularity: 0,
                posterPath: path,
                releaseDate: "",
                title: "",
                video: false,
                voteAverage: 0,
                voteCount: 0,
                rating: 0
            )],
            totalPages: 1,
            totalResults: 1
        )
        return Observable.just(movieListDTO)
    }
    
    func getGenresList() -> Observable<GenresDTO> {
        getGenresListCallCount += 1
        
        let genresDTO = GenresDTO(genres: [Genre(id: 0, name: "")])
        return Observable.just(genresDTO)
    }
    
    func getSearchResultList(with keyword: String, page: Int) -> Observable<MovieListDTO> {
        getSearchResultListCallCount += 1
        
        let movieListDTO = MovieListDTO(
            dates: DatesDTO(maximum: "", minimum: ""),
            page: 1,
            results: [MovieListItemDTO(
                adult: false,
                backdropPath: "",
                genreIDS: [0],
                id: 1,
                originalLanguage: "",
                originalTitle: "",
                overview: "",
                popularity: 0,
                posterPath: "",
                releaseDate: "",
                title: keyword,
                video: false,
                voteAverage: 0,
                voteCount: 0,
                rating: 0
            )],
            totalPages: 1,
            totalResults: 1
        )
        return Observable.just(movieListDTO)
    }
    
    func getOmdbMovieDetail(with id: Int) -> Observable<OMDBMovieDetailDTO> {
        getOmdbMovieDetailCallCount += 1
        
        let omdbMovieDetailDTO = OMDBMovieDetailDTO(
            title: "",
            year: "1000",
            rated: "",
            released: "",
            runtime: "",
            genre: "",
            director: "",
            writer: "",
            actors: "",
            plot: "",
            language: "",
            country: "",
            awards: "",
            poster: "",
            ratings: [RatingDTO(source: "", value: "")],
            metascore: "",
            imdbRating: "",
            imdbVotes: "",
            imdbID: "id",
            type: "",
            dvd: "",
            boxOffice: "",
            production: "",
            website: "",
            response: ""
        )
        return Observable.just(omdbMovieDetailDTO)
    }
    
    func getTmdbMovieDetail(with id: Int) -> Observable<TMDBMovieDetailDTO> {
        getTmdbMovieDetailtCallCount += 1
        
        let tmdbMovieDetailDTO = TMDBMovieDetailDTO(
            adult: false,
            backdropPath: "",
            collection: CollectionDTO(
                id: 0,
                name: "",
                posterPath: "",
                backdropPath: ""
            ),
            budget: 0,
            genres: [Genre(id: 0, name: "")],
            homepage: "",
            id: id,
            imdbID: "id",
            originalLanguage: "",
            originalTitle: "",
            overview: "",
            popularity: 0,
            posterPath: "",
            productionCompanies: [ProductionCompanyDTO(
                id: 0,
                logoPath: "",
                name: "",
                originCountry: ""
            )],
            productionCountries: [ProductionCountryDTO(
                iso3166_1: "",
                name: ""
            )],
            releaseDate: "",
            revenue: 0,
            runtime: 0,
            spokenLanguages: [SpokenLanguageDTO(
                englishName: "",
                iso639_1: "",
                name: ""
            )],
            status: "",
            tagLine: "",
            title: "nope",
            video: false,
            voteAverage: 0,
            voteCount: 0
        )
        return Observable.just(tmdbMovieDetailDTO)
    }
    
    func getMovieDetailReviews(with id: Int) -> Observable<ReviewListDTO> {
        getMovieDetailReviewsCallCount += 1
        
        let reviewListDTO = ReviewListDTO(
            id: 0,
            page: 0,
            results: [
                ReviewDTO(
                    author: "",
                    authorDetails: AuthorDetailsDTO(
                        name: "",
                        username: "",
                        avatarPath: "",
                        rating: 2.5
                    ),
                    content: "This is a short form review ",
                    createdAt: "",
                    id: "id",
                    updatedAt: "",
                    url: ""
                ),
                ReviewDTO(
                    author: "",
                    authorDetails: AuthorDetailsDTO(
                        name: "",
                        username: "",
                        avatarPath: "",
                        rating: 3
                    ),
                    content: "**This is a long form review initially published in 2011:**\r\n\r\nThough it ran at over two hours, I did feel that it had plenty of room to go further than it did. I honestly felt like Red Skull could have had a film all to himself, and actually kind of suffered for making him as intriguing as he was.\r\n\r\nChris Evans was an interesting choice as the titular role of Captain America, given that he's already played American sweetheart Marvel Super Hero \"The Human Torch\" in _Fantastic 4_ and _Fantastic 4: Rise of the Silver Surfer_. He didn't Oh-My-Gosh blow me away type-thing or what have you, but he was pretty great.\r\n\r\nSo far in the Marvel Cinematic Universe, I'd slot Captain America clean in the middle. I liked _Iron Man_ and _Thor_ more, but _Iron Man 2_ and _The Incredible Hulk_ less. Marvel Studios stated that the movie they wanted to make was set in the 40's, even though the rest of Marvel Cinematic is modern-day.",
                    createdAt: "",
                    id: "",
                    updatedAt: "",
                    url: ""
                )
            ],
            totalPages: 0,
            totalResults: 0
        )
        return Observable.just(reviewListDTO)
    }
    
    func verifyGetMovieList(callCount: Int) {
        XCTAssertEqual(getMovieListCallCount, callCount)
    }
    
    func verifyGetGenresList(callCount: Int) {
        XCTAssertEqual(getGenresListCallCount, callCount)
    }
    
    func verifyGetSearchResultList(callCount: Int) {
        XCTAssertEqual(getSearchResultListCallCount, callCount)
    }
    
    func verifyGetOmdbMovieDetail(callCount: Int) {
        XCTAssertEqual(getOmdbMovieDetailCallCount, callCount)
    }
    
    func verifyGetTmdbMovieDetail(callCount: Int) {
        XCTAssertEqual(getTmdbMovieDetailtCallCount, callCount)
    }
    
    func verifyGetMovieDetailReviews(callCount: Int) {
        XCTAssertEqual(getMovieDetailReviewsCallCount, callCount)
    }

    

}

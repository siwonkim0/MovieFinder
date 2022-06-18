//
//  FakeDefaultMoviesUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/06/17.
//

import UIKit
import RxSwift
@testable import MovieFinder

class FakeDefaultMoviesUseCase: MoviesUseCase {
    func getMovieListItem(from listUrl: MovieListURL) -> Observable<[MovieListItem]> {
        return Observable.create { observer in
            observer.onNext([MovieListItem(id: 338953, title: "Fantastic Beasts: The Secrets of Dumbledore", overview: "Professor Albus Dumbledore knows the powerful, dark wizard Gellert Grindelwald is moving to seize control of the wizarding world. Unable to stop him alone, he entrusts magizoologist Newt Scamander to lead an intrepid team of wizards and witches. They soon encounter an array of old and new beasts as they clash with Grindelwald's growing legion of followers.", releaseDate: "2022-04-06", posterPath: "/jrgifaYeUtTnaH7NF5Drkgjg2MB.jpg", originalLanguage: .english, genres: [Genre(id: 28, name: "Adventure")]),
                             MovieListItem(id: 338953, title: "Fantastic Beasts: The Secrets of Dumbledore", overview: "Professor Albus Dumbledore knows the powerful, dark wizard Gellert Grindelwald is moving to seize control of the wizarding world. Unable to stop him alone, he entrusts magizoologist Newt Scamander to lead an intrepid team of wizards and witches. They soon encounter an array of old and new beasts as they clash with Grindelwald's growing legion of followers.", releaseDate: "2022-04-06", posterPath: "/jrgifaYeUtTnaH7NF5Drkgjg2MB.jpg", originalLanguage: .english, genres: [Genre(id: 28, name: "Adventure")])])
            return Disposables.create()
        }
    }
}

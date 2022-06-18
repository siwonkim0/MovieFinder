//
//  MovieListViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/06/17.
//

import XCTest
import RxSwift
import RxTest
import Nimble
import RxNimble
@testable import MovieFinder

class MovieListViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    var viewModel: MovieListViewModel!
    var output: MovieListViewModel.Output!
    var viewWillAppear: PublishSubject<Void>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        viewModel = MovieListViewModel(defaultMoviesUseCase: FakeDefaultMoviesUseCase())
        viewWillAppear = PublishSubject<Void>()
        output = viewModel.transform(MovieListViewModel.Input(viewWillAppear: viewWillAppear.asObservable()))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCountedValue() {
        scheduler.createColdObservable([
            .next(1, ())
        ]).bind(to: self.viewWillAppear).disposed(by: disposeBag)
        
        expect(self.output.sectionObservable.map { $0.count })
            .events(scheduler: scheduler, disposeBag: disposeBag)
            .to(equal([.next(1, 4) ]))
    }


}

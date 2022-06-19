//
//  AuthViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/06/19.
//

import XCTest
import RxSwift
import RxTest
import Nimble
import RxNimble
@testable import MovieFinder

class AuthViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    var viewModel: AuthViewModel!
    var output: AuthViewModel.Output!
    var didTapOpenUrlWithToken: PublishSubject<Void>!
    var didTapAuthDone: PublishSubject<Void>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        viewModel = AuthViewModel(repository: FakeAuthRepository())
        
        didTapOpenUrlWithToken = PublishSubject<Void>()
        didTapAuthDone = PublishSubject<Void>()
        output = viewModel.transform(AuthViewModel.Input(didTapOpenUrlWithToken: didTapOpenUrlWithToken.asObservable(), didTapAuthDone: didTapAuthDone.asObservable()))
    }
    
    func test() {
        //input: 버튼탭 이벤트 , output 넘겨준 가짜토큰을 잘 포함해서 URL이 만들어졌는지
        scheduler.createColdObservable([
            .next(1, ())
        ]).bind(to: self.didTapOpenUrlWithToken).disposed(by: disposeBag)
        
        expect(self.output.tokenUrl)
            .events(scheduler: scheduler, disposeBag: disposeBag)
            .to(equal([.next(1, URL(string: "https://www.themoviedb.org/authenticate/161b570e5098669317e497a56394280599ed0a85")!) ]))
        

        
    }
    
    func test2() {
        scheduler.createColdObservable([
            .next(2, ())
        ]).bind(to: self.didTapAuthDone).disposed(by: disposeBag)
        
        //output이 void일때는 어떻게 표현?? 일단 리턴값을 bool로 바꿔보긴 핵는데
        expect(self.output.didCreateAccount)
            .events(scheduler: scheduler, disposeBag: disposeBag)
            .to(equal([.next(2, false)]))
    }

}

//
//  AuthUseCaseTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

class AuthUseCaseTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var authRepository: MockAuthRepository!
    private var accountRepository: MockAccountRepository!
    private var useCase: AuthUseCase!
    
    override func setUp() {
        disposeBag = DisposeBag()
        authRepository = MockAuthRepository()
        accountRepository = MockAccountRepository()
        useCase = AuthUseCase(authRepository: authRepository, accountRepository: accountRepository)
    }
    
    func test_getUrlWithToken() {
        useCase.getUrlWithToken()
            .subscribe(onNext: { url in
                XCTAssertEqual(url, URL(string: ""))
                self.authRepository.verifyMakeUrlWithToken(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_createSessionIdWithToken() {
        useCase.createSessionIdWithToken()
            .subscribe(onNext: { void in
                self.authRepository.verifyCreateSessionIdWithToken(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_saveAccountId() {
        useCase.saveAccountId()
            .subscribe(onNext: { data in
                XCTAssertEqual(data, Data())
                self.accountRepository.verifySaveAccountId(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
}

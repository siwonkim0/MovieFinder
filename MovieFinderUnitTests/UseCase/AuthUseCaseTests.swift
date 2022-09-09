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
    private var authRepository: SpyAuthRepository!
    private var accountRepository: SpyAccountRepository!
    private var useCase: AuthUseCase!
    
    override func setUp() {
        disposeBag = DisposeBag()
        authRepository = SpyAuthRepository()
        accountRepository = SpyAccountRepository()
        useCase = AuthUseCase(authRepository: authRepository, accountRepository: accountRepository)
    }
    
    func test_getUrlWithToken() {
        useCase.getUrlWithToken()
            .subscribe(onNext: { url in
                XCTAssertEqual(url, URL(string: "url"))
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

////
////  FakeAuthRepository.swift
////  MovieFinderUnitTests
////
////  Created by Siwon Kim on 2022/06/19.
////
//
//import UIKit
//import RxSwift
//@testable import MovieFinder
//
//class FakeAuthRepository: MovieAuthRepository {
//    func getToken(from url: URL?) -> Observable<Token> {
//        return Observable.create { observer in
//            observer.onNext(Token(success: true,
//                                  expiresAt: "2022-06-18 17:06:57 UTC",
//                                  requestToken: "161b570e5098669317e497a56394280599ed0a85"))
//            return Disposables.create()
//        }
//    }
//    
//    func createSession(with token: Data?, to url: URL?, format: Session.Type) -> Observable<Session> {
//        return Observable.create { observer in
//            observer.onNext(Session(success: true,
//                                    sessionID: "fd602cffb52be84807651241bc99e2cf4508297f",
//                                    statusCode: nil,
//                                    statusMessage: nil))
//            return Disposables.create()
//        }
//    }
//}

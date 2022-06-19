//
//  MovieAuthRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

protocol MovieAuthRepository {
    func getToken(from url: URL?) -> Observable<Token>
    func createSession(with token: Data?, to url: URL?, format: Session.Type) -> Observable<Session>
}

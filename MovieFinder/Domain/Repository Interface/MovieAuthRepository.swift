//
//  MovieAuthRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

protocol MovieAuthRepository {
    func makeUrlWithToken() -> Observable<URL>
    func createSessionIdWithToken() -> Observable<Void>
    func isSessionIdExisting() -> Bool
}

//
//  MovieAccountRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/13.
//

import Foundation
import RxSwift

protocol MovieAccountRepository {
    func getAccountID() -> Observable<Data>
}

//
//  ObservableType+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/24.
//

import Foundation
import RxSwift

extension ObservableType {
    func filterErrors() -> Observable<Element> {
        return materialize()
            .filter { $0.element != nil }
            .dematerialize()
    }
}

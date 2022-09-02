//
//  Expectation+extension.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/06/17.
//

import Foundation
import RxSwift
import RxTest
import Nimble
import RxNimble

public extension Expectation where T: ObservableConvertibleType {

    internal func transform<U>(_ closure: @escaping (T?) throws -> U?) -> Expectation<U> {
        let exp = expression.cast(closure)
        return Expectation<U>(expression: exp)
    }

    func events(scheduler: TestScheduler,
                disposeBag: DisposeBag,
                startAt initialTime: Int = 0) -> Expectation<[Recorded<Event<T.Element>>]> {
        return transform { source in
            let results = scheduler.createObserver(T.Element.self)

            scheduler.scheduleAt(initialTime) {
                source?.asObservable().subscribe(results).disposed(by: disposeBag)
            }
            scheduler.start()

            return results.events
        }
    }
}

public func equal<Void>(_ expectedValue: Void?) -> Predicate<Void> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        default:
            var isEqual = false

            if String(describing: expectedValue).count != 0, String(describing: expectedValue) == String(describing: actualValue) {
                isEqual = true
            }
            return PredicateResult(bool: isEqual, message: msg)
        }
    }
}

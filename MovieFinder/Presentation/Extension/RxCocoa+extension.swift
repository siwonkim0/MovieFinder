//
//  RxCocoa+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/15.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let viewWillAppearEvent = self.methodInvoked(#selector(base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: viewWillAppearEvent)
    }
}

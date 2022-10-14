//
//  AuthViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit

protocol AuthViewControllerDelegate: AnyObject {
    func didFinishLogin()
    func showTabBarController(at viewController: UIViewController)
}

final class AuthViewController: UIViewController, StoryboardView {
    @IBOutlet var openUrlWithTokenButton: UIButton!
    private let sceneDidBecomeActiveSubject = PublishSubject<Void>()
    var disposeBag = DisposeBag()
    weak var coordinator: AuthViewControllerDelegate?

    init?(reactor: AuthReactor, coder: NSCoder) {
        super.init(coder: coder)
        defer {
            self.reactor = reactor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSceneWillEnterForegroundObserver()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinishLogin()
    }
    
    func bind(reactor: AuthReactor) {
        bindAction(reactor)
        bindState(reactor)
    }

    private func bindAction(_ reactor: AuthReactor) {
        openUrlWithTokenButton.rx.tap.asObservable()
            .map { Reactor.Action.openURL }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sceneDidBecomeActiveSubject.asObservable()
            .map { Reactor.Action.authenticate }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: AuthReactor) {
        reactor.pulse(\.$url)
            .skip(1)
            .asDriver(onErrorJustReturn: URL(string: ""))
            .drive(with: self, onNext: { (self, url) in
                guard let url = url else {
                    return
                }
                if UIApplication.shared.canOpenURL(url) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isAuthDone)
            .skip(1)
            .retry()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { (self, _) in
                self.coordinator?.showTabBarController(at: self)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Notification
    private func addSceneWillEnterForegroundObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(AuthViewController.sceneDidBecomeActive), name: UIScene.didActivateNotification, object: nil)
    }
    
    @objc private func sceneDidBecomeActive(notification: NSNotification) {
        sceneDidBecomeActiveSubject.onNext(())
    }
}

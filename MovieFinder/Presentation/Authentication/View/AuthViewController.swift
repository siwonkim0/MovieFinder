//
//  AuthViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit
import RxCocoa
import RxSwift

protocol AuthViewControllerDelegate: AnyObject {
    func didFinishLogin()
    func showTabBarController(at viewController: UIViewController)
}

final class AuthViewController: UIViewController {
    @IBOutlet weak var openUrlWithTokenButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let viewModel: AuthViewModel
    private let sceneDidBecomeActiveSubject = PublishSubject<Void>()
    weak var coordinator: AuthViewControllerDelegate?

    init?(viewModel: AuthViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSceneWillEnterForegroundObserver()
        configureBind()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinishLogin()
    }
    
    private func addSceneWillEnterForegroundObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(AuthViewController.sceneDidBecomeActive), name: UIScene.didActivateNotification, object: nil)
    }
    
    @objc private func sceneDidBecomeActive(notification: NSNotification) {
        sceneDidBecomeActiveSubject.onNext(())
    }
    
    func configureBind() {
        let input = AuthViewModel.Input(
            didTapOpenUrlWithToken: openUrlWithTokenButton.rx.tap.asObservable(),
            sceneDidBecomeActive: sceneDidBecomeActiveSubject
                .asObservable()
        )
        
        let output = viewModel.transform(input)
        output.tokenUrl
            .subscribe(onNext: { url in
                if UIApplication.shared.canOpenURL(url) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }).disposed(by: disposeBag)

        output.didSaveSessionId
            .retry()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { (self, _) in
                self.coordinator?.showTabBarController(at: self)
            }).disposed(by: disposeBag)
    }
}

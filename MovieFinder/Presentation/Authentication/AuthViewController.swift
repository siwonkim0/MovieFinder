//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit
import RxCocoa
import RxSwift

protocol AuthViewControllerDelegate {
    func login()
    func didFinishLogin()
}

final class AuthViewController: UIViewController {
    @IBOutlet weak var openUrlWithTokenButton: UIButton!
    @IBOutlet weak var authDoneButton: UIButton!
    
    let disposeBag = DisposeBag()
    let viewModel: AuthViewModel
    var coordinator: AuthViewControllerDelegate?

    init?(viewModel: AuthViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBind()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinishLogin()
    }
    
    func configureBind() {
        let input = AuthViewModel.Input(didTapOpenUrlWithToken: openUrlWithTokenButton.rx.tap.asObservable(), didTapAuthDone: authDoneButton.rx.tap.asObservable(), viewWillDisappear: self.rx.viewWillDisappear.asObservable())
        
        let output = viewModel.transform(input)
        output.tokenUrl
            .subscribe(onNext: { url in
                if UIApplication.shared.canOpenURL(url) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }).disposed(by: disposeBag)
        
        output.didCreateAccount
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("로그인 완료! 이제 메인으로 고고")
                print("account", KeychainManager.shared.getAccountID())
                self.coordinator?.login()
            }).disposed(by: disposeBag)
        
        output.didSaveAccountID
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("account", KeychainManager.shared.getAccountID())
            }).disposed(by: disposeBag)
    }
}

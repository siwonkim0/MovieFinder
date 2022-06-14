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
    let viewModel = AuthViewModel()
    var coordinator: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBind()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinishLogin()
        
    }
    
    func configureBind() {
        let input = AuthViewModel.Input(didTapOpenUrlWithToken: openUrlWithTokenButton.rx.tap.asObservable(), didTapAuthDone: authDoneButton.rx.tap.asObservable())
        
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
            .subscribe(onNext: {
                print("로그인 완료! 이제 메인으로 고고 ")
                self.coordinator?.login()
            }).disposed(by: disposeBag)
    }
}

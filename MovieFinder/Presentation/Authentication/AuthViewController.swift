//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

protocol AuthViewControllerDelegate {
    func login()
    func didFinishLogin()
}

final class AuthViewController: UIViewController {
    let viewModel = AuthViewModel()
    var coordinator: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.didFinishLogin()
    }
    
    @IBAction func openURL(_ sender: Any) {
        Task {
            await viewModel.directToSignUpPage()
        }
    }
    
    @IBAction func createSessionID(_ sender: Any) {
        Task {
            await viewModel.saveSessionID()
        }
        self.coordinator?.login()
    }
    
    @IBAction func checkExistingID(_ sender: Any) {
        KeychainManager.shared.checkExistingSession()
        print(KeychainManager.shared.isExisting)
    }
}

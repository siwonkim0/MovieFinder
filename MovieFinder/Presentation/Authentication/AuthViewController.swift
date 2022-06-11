//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

protocol AuthViewControllerDelegate {
    func login()
}

final class AuthViewController: UIViewController {
    let viewModel = AuthViewModel()
    var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.delegate?.login()
    }
    
    @IBAction func checkExistingID(_ sender: Any) {
        KeychainManager.shared.checkExistingSession()
        print(KeychainManager.shared.isExisting)
    }
}

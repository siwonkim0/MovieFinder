//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

protocol AuthenticationViewControllerDelegate {
    func login()
}

final class AuthenticationViewController: UIViewController {
    let viewModel = AuthenticationViewModel()
    var delegate: AuthenticationViewControllerDelegate?
    
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

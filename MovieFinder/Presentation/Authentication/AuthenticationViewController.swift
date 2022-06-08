//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

final class AuthenticationViewController: UIViewController {
    let viewModel = AuthenticationViewModel()
    
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
    }
    
    @IBAction func checkExistingID(_ sender: Any) {
        KeychainManager.shared.checkExistingSession()
        print(KeychainManager.shared.isExisting)
    }
}

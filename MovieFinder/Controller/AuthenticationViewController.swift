//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

final class AuthenticationViewController: UIViewController {
    @IBOutlet weak var posterImage: UIImageView!
    let viewModel = AuthenticationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openURL(_ sender: Any) {
        viewModel.getToken()
    }
    
    @IBAction func createSessionID(_ sender: Any) {
        viewModel.createSessionID()
    }
    
    @IBAction func checkExistingID(_ sender: Any) {
        KeychainManager.shared.checkExistingSession()
        print(KeychainManager.shared.isExisting)
    }
}

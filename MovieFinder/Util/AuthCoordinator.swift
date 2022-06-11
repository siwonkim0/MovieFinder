//
//  LoginCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol AuthCoordinatorDelegate {
    func didLoggedIn(_ coordinator: AuthCoordinator)
}

class AuthCoordinator: Coordinator, AuthenticationViewControllerDelegate {
    var delegate: AuthCoordinatorDelegate?
    let window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "AuthenticationViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController else {
            return
        }
        viewController.delegate = self
        window?.rootViewController = viewController
    }
    
    func login() {
        delegate?.didLoggedIn(self)
    }
    
    
}

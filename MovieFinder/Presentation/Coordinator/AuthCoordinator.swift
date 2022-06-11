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

class AuthCoordinator: Coordinator, AuthViewControllerDelegate {
    weak var parentCoordinator: AppCoordinator?
    var delegate: AuthCoordinatorDelegate?
    let window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "AuthViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        viewController.coordinator = self
        window?.rootViewController = viewController
    }
    
    func login() {
        delegate?.didLoggedIn(self)
    }
    
    func didFinishLogin() {
        parentCoordinator?.childDidFinish(self)
    }
    
    
}

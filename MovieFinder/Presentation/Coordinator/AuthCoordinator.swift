//
//  LoginCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func didLoggedIn(_ coordinator: AuthCoordinator)
    func childDidFinish(_ child: Coordinator)
}

class AuthCoordinator: Coordinator, AuthViewControllerDelegate {
    //엥 weak를 쓰면 안된다
    var parentCoordinator: AuthCoordinatorDelegate?
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
        parentCoordinator?.didLoggedIn(self)
    }
    
    func didFinishLogin() {
        parentCoordinator?.childDidFinish(self)
    }
    
    
}

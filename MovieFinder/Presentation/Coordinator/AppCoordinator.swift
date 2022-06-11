//
//  AppCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

class AppCoordinator: Coordinator, AuthCoordinatorDelegate {
    var childCoordinators = [Coordinator]()
    var isloggedIn: Bool = false
    var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        checkLoginStatus()
        if isloggedIn {
            showListViewController()
        } else {
            showLoginViewController()
        }
    }
    
    private func checkLoginStatus() {
        KeychainManager.shared.checkExistingSession()
        if KeychainManager.shared.isExisting {
            isloggedIn = true
        } else {
            isloggedIn = false
        }
    }
    
    private func showListViewController() {
        let coordinator = MovieListCoordinator(window: window)
        childCoordinators.append(coordinator)
        coordinator.start()
        
    }
    
    private func showLoginViewController() {
        let coordinator = AuthCoordinator(window: window)
        coordinator.delegate = self
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func didLoggedIn(_ coordinator: AuthCoordinator) {
        self.showListViewController()
    }
    
    func childDidFinish(_ child: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
}

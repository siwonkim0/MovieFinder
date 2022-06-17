//
//  AppCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    
    func start()
}

class AppCoordinator: Coordinator, AuthCoordinatorDelegate, MovieListCoordinatorDelegate {
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
        let coordinator = MovieListCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let listVC = coordinator.setViewController()
        window?.rootViewController = listVC
    }
    
    private func showLoginViewController() {
        let coordinator = AuthCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let authVC = coordinator.setViewController()
        window?.rootViewController = authVC
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

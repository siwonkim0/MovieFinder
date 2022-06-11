//
//  AppCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol Coordinator {
    func start()
}

class AppCoordinator: Coordinator, AuthCoordinatorDelegate {
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
        coordinator.start()
        
    }
    
    private func showLoginViewController() {
        let coordinator = AuthCoordinator(window: window)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func didLoggedIn(_ coordinator: AuthCoordinator) {
        self.showListViewController()
    }
    
}

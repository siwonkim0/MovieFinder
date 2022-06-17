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
            window?.rootViewController = tabBarController()
        } else {
            window?.rootViewController = authViewController()
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
    
    private func tabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let listNC = setListViewController()
        listNC.tabBarItem = UITabBarItem(
            title: "MovieList",
            image: UIImage(named: "star"),
            tag: 0)
        
        tabBarController.viewControllers = [listNC]
        return tabBarController
    }
    
    private func setListViewController() -> UINavigationController {
        let coordinator = MovieListCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let listNC = coordinator.setViewController()
        return listNC
    }
    
    private func authViewController() -> UIViewController {
        let coordinator = AuthCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let authVC = coordinator.setViewController()
        return authVC
    }
    
    func didLoggedIn(_ coordinator: AuthCoordinator) {
        window?.rootViewController = tabBarController()
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

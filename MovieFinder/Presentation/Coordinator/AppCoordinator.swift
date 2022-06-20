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

class AppCoordinator: Coordinator, AuthCoordinatorDelegate, MovieListCoordinatorDelegate, SearchCoordinatorDelegate, MyAccountCoordinatorDelegate {
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
        
        let listNC = listViewController()
        listNC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0)
        
        let searchNC = searchViewController()
        searchNC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 1)
        
        let myAccountNC = myAccountViewController()
        myAccountNC.tabBarItem = UITabBarItem(
            title: "My Account",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 2)
        
        tabBarController.viewControllers = [listNC, searchNC, myAccountNC]
        tabBarController.tabBar.backgroundColor = .clear
        return tabBarController
    }
    
    private func listViewController() -> UINavigationController {
        let coordinator = MovieListCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let listNC = coordinator.setViewController()
        return listNC
    }
    
    private func searchViewController() -> UINavigationController {
        let coordinator = SearchCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let searchNC = coordinator.setViewController()
        return searchNC
    }
    
    private func myAccountViewController() -> UINavigationController {
        let coordinator = MyAccountCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let myAccountNC = coordinator.setViewController()
        return myAccountNC
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
    
    func showDetailViewController(at viewController: UIViewController, of id: Int) {
        let storyboard = UIStoryboard(name: "MovieDetailViewController", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "MovieDetailViewController") as? MovieDetailViewController else {
            return
        }
        
        if let vc = viewController as? MovieListViewController {
            vc.navigationController?.pushViewController(detailViewController, animated: true)
        } else if let vc = viewController as? SearchViewController {
            vc.navigationController?.pushViewController(detailViewController, animated: true)
        } else if let vc = viewController as? MyAccountViewController {
            vc.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
}

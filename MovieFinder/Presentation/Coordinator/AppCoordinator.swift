//
//  AppCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    
    func start() -> UINavigationController
}

class AppCoordinator: Coordinator, AuthCoordinatorDelegate, MovieListCoordinatorDelegate, SearchCoordinatorDelegate, MyAccountCoordinatorDelegate {
    var childCoordinators = [Coordinator]()
    var isloggedIn: Bool = false
    var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }
    
    @discardableResult
    func start() -> UINavigationController {
        checkLoginStatus()
        if isloggedIn {
            window?.rootViewController = tabBarController()
        } else {
            window?.rootViewController = authNavigationController()
        }
        window?.makeKeyAndVisible()
        return UINavigationController()
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
        
        let listNC = listNavigationController()
        listNC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0)
        
        let searchNC = searchNavigationController()
        searchNC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 1)
        
        let myAccountNC = myAccountNavigationController()
        myAccountNC.tabBarItem = UITabBarItem(
            title: "My Account",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 2)
        
        tabBarController.viewControllers = [listNC, searchNC, myAccountNC]
        tabBarController.tabBar.backgroundColor = .clear
        return tabBarController
    }
    
    private func listNavigationController() -> UINavigationController {
        let coordinator = MovieListCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let listNC = coordinator.start()
        return listNC
    }
    
    private func searchNavigationController() -> UINavigationController {
        let coordinator = SearchCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let searchNC = coordinator.start()
        return searchNC
    }
    
    private func myAccountNavigationController() -> UINavigationController {
        let coordinator = MyAccountCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let myAccountNC = coordinator.start()
        return myAccountNC
    }

    private func authNavigationController() -> UINavigationController {
        let coordinator = AuthCoordinator()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        let authNC = coordinator.start()
        return authNC
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
            let moviesRepository = DefaultMoviesRepository(urlSessionManager: URLSessionManager())
            let defaultMoviesUseCase = DefaultMoviesUseCase(moviesRepository: moviesRepository)
            let viewModel = MovieDetailViewModel(movieID: id, useCase: defaultMoviesUseCase)
            let detailViewController = MovieDetailViewController(viewModel: viewModel)

        if let vc = viewController as? MovieListViewController {
            vc.navigationController?.pushViewController(detailViewController, animated: true)
        } else if let vc = viewController as? SearchViewController {
            vc.navigationController?.pushViewController(detailViewController, animated: true)
        } else if let vc = viewController as? MyAccountViewController {
            vc.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
}

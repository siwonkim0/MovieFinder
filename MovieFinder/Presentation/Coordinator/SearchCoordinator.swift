//
//  SearchCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/17.
//

import UIKit

protocol SearchCoordinatorDelegate: AnyObject {
    
}

class SearchCoordinator: Coordinator, SearchViewControllerDelegate {
    weak var parentCoordinator: SearchCoordinatorDelegate?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() -> UINavigationController {
        let searchViewController = setViewController()
        return setNavigationController(with: searchViewController)
    }
    
    private func setViewController() -> UIViewController {
        let viewController = SearchViewController()
        viewController.coordinator = self
        return viewController
    }
    
    private func setNavigationController(with viewController: UIViewController) -> UINavigationController {
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.topItem?.title = "Search"
        return navigationController
    }
}

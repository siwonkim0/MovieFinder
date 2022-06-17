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
    
    func start() {
        
    }
    
    func setViewController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "SearchViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            return UINavigationController()
        }
        viewController.coordinator = self
        
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.topItem?.title = "Search"
        return navigationController
    }
}

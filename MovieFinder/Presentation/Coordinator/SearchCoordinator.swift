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
        let urlSessionManager = URLSessionManager()
        let moviesRepository = DefaultMoviesRepository(urlSessionManager: urlSessionManager)
        let accountRepository = AccountRepository(urlSessionManager: urlSessionManager)
        let defaultMoviesUseCase = DefaultMoviesUseCase(moviesRepository: moviesRepository, accountRepository: accountRepository)
        let viewModel = SearchViewModel(useCase: defaultMoviesUseCase)
        let viewController = SearchViewController(viewModel: viewModel)
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

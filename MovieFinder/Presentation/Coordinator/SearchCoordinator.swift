//
//  SearchCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/17.
//

import UIKit

protocol SearchCoordinatorDelegate: AnyObject {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

class SearchCoordinator: Coordinator, SearchViewControllerDelegate {
    weak var parentCoordinator: SearchCoordinatorDelegate?
    var childCoordinators = [Coordinator]()
    private var navigationController = UINavigationController()
    
    func start() -> UINavigationController {
        let searchViewController = setViewController()
        return setNavigationController(with: searchViewController)
    }
    
    private func setViewController() -> UIViewController {
        let urlSessionManager = URLSessionManager()
        let moviesRepository = DefaultMoviesRepository(urlSessionManager: urlSessionManager)
        let defaultMoviesUseCase = DefaultMoviesUseCase(moviesRepository: moviesRepository)
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
    
    func showDetailViewController(at viewController: UIViewController, of id: Int) {
        parentCoordinator?.showDetailViewController(at: viewController, of: id)
    }
}

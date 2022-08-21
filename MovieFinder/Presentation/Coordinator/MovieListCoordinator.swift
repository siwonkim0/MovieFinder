//
//  MainCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol MovieListCoordinatorDelegate: AnyObject {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

class MovieListCoordinator: Coordinator, MovieListViewControllerDelegate {
    weak var parentCoordinator: MovieListCoordinatorDelegate?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() -> UINavigationController {
        let detailViewController = setViewController()
        return setNavigationController(with: detailViewController)
    }

    private func setViewController() -> UIViewController {
        let urlSessionManager = URLSessionManager()
        let moviesRepository = DefaultMoviesRepository(urlSessionManager: urlSessionManager)
        let accountRepository = AccountRepository(urlSessionManager: urlSessionManager)
        let defaultMoviesUseCase = DefaultMoviesUseCase(moviesRepository: moviesRepository, accountRepository: accountRepository)
        let viewModel = MovieListViewModel(defaultMoviesUseCase: defaultMoviesUseCase)
        let viewController = MovieListViewController(viewModel: viewModel)
        viewController.coordinator = self
        return viewController
    }
    
    private func setNavigationController(with viewController: UIViewController) -> UINavigationController {
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.topItem?.title = "Home"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        return navigationController
    }
    
    func showDetailViewController(at viewController: UIViewController, of id: Int) {
        parentCoordinator?.showDetailViewController(at: viewController, of: id)
    }
}

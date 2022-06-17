//
//  MainCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol MovieListCoordinatorDelegate: AnyObject {

}

class MovieListCoordinator: Coordinator, MovieListViewControllerDelegate {
    weak var parentCoordinator: MovieListCoordinatorDelegate?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        
    }

    func setViewController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "MovieListViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: "MovieListViewController", creator: { creater in
            let viewModel = MovieListViewModel(defaultMoviesUseCase: DefaultMoviesUseCase(moviesRepository: DefaultMoviesRepository(apiManager: APIManager())))
            let viewController = MovieListViewController(viewModel: viewModel, coder: creater)
            return viewController
        }) as? MovieListViewController else {
            return UINavigationController()
        }
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.topItem?.title = "Home"
        return navigationController
    }
}

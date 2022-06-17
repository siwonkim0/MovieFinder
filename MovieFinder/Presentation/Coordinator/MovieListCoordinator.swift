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

    func start() {
        
    }

    func setViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "MovieListViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: "MovieListViewController", creator: { creater in
            let viewModel = MovieListViewModel(defaultMoviesUseCase: DefaultMoviesUseCase(moviesRepository: DefaultMoviesRepository(apiManager: APIManager())))
            let viewController = MovieListViewController(viewModel: viewModel, coder: creater)
            return viewController
        }) as? MovieListViewController else {
            return UIViewController()
        }
        viewController.coordinator = self
        return viewController
    }
}

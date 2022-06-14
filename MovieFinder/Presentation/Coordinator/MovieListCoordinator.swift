//
//  MainCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol MovieListCoordinatorDelegate: AnyObject {

}

class MovieListCoordinator: Coordinator {
    weak var parentCoordinator: MovieListCoordinatorDelegate?
    let window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        let storyboard = UIStoryboard(name: "MovieListViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "MovieListViewController", creator: { creater in
            let viewModel = MovieListViewModel(defaultMoviesUseCase: DefaultMoviesUseCase(moviesRepository: DefaultMoviesRepository(apiManager: APIManager())))
            let viewController = MovieListViewController(viewModel: viewModel, coder: creater)
            return viewController
        })
        window?.rootViewController = viewController
    }
}

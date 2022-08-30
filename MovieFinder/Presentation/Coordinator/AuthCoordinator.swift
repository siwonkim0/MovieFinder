//
//  AuthCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func childDidFinish(_ child: Coordinator)
    func showTabBarController(at viewController: UIViewController)
}

class AuthCoordinator: Coordinator, AuthViewControllerDelegate {
    weak var parentCoordinator: AuthCoordinatorDelegate?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() -> UINavigationController {
        let authViewController = setViewController()
        return setNavigationController(with: authViewController)
    }
    
    private func setViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "AuthViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: "AuthViewController", creator: { creater in
            let urlSessionManager = URLSessionManager()
            let useCase = AuthUseCase(authRepository: AuthRepository(urlSessionManager: urlSessionManager), accountRepository: AccountRepository(urlSessionManager: urlSessionManager))
            let viewModel = AuthViewModel(useCase: useCase)
            let viewController = AuthViewController(viewModel: viewModel, coder: creater)
            return viewController
        }) as? AuthViewController else {
            return UIViewController()
        }
        
        viewController.coordinator = self
        return viewController
    }
    
    private func setNavigationController(with viewController: UIViewController) -> UINavigationController {
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }
    
    func didFinishLogin() {
        parentCoordinator?.childDidFinish(self)
    }
    
    func showTabBarController(at viewController: UIViewController) {
        parentCoordinator?.showTabBarController(at: viewController) 
    }
    
}

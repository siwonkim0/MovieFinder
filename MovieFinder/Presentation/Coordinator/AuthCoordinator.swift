//
//  LoginCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/11.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func didLoggedIn(_ coordinator: AuthCoordinator)
    func childDidFinish(_ child: Coordinator)
}

class AuthCoordinator: Coordinator, AuthViewControllerDelegate {
    weak var parentCoordinator: AuthCoordinatorDelegate?
    var childCoordinators = [Coordinator]()

    func start() {
        
    }
    
    func setViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "AuthViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: "AuthViewController", creator: { creater in
            let apiManager = APIManager()
            let useCase = AuthUseCase(authRepository: AuthRepository(apiManager: apiManager), accountRepository: AccountRepository(apiManager: apiManager))
            let viewModel = AuthViewModel(useCase: useCase)
            let viewController = AuthViewController(viewModel: viewModel, coder: creater)
            return viewController
        }) as? AuthViewController else {
            return UIViewController()
        }
        
        viewController.coordinator = self
        return viewController
    }
    
    func login() {
        parentCoordinator?.didLoggedIn(self)
    }
    
    func didFinishLogin() {
        parentCoordinator?.childDidFinish(self)
    }
    
    
}

//
//  MyAccountCoordinator.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/17.
//

import UIKit

protocol MyAccountCoordinatorDelegate: AnyObject {
    
}

class MyAccountCoordinator: Coordinator, MyAccountViewControllerDelegate {
    weak var parentCoordinator: MyAccountCoordinatorDelegate?
    var childCoordinators = [Coordinator]()
    private var navigationController = UINavigationController()
    
    func start() -> UINavigationController {
        let myAccountViewController = setViewController()
        return setNavigationController(with: myAccountViewController)
    }
    
    private func setViewController() -> UIViewController {
        let viewController = MyAccountViewController()
        viewController.coordinator = self
        return viewController
    }
    
    private func setNavigationController(with viewController: UIViewController) -> UINavigationController {
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.topItem?.title = "My Account"
        return navigationController
    }
}

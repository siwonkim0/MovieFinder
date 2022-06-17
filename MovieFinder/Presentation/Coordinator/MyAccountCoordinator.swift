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
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        
    }
    
    func setViewController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "MyAccountViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "MyAccountViewController") as? MyAccountViewController else {
            return UINavigationController()
        }
        viewController.coordinator = self
        
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.topItem?.title = "My Account"
        return navigationController
    }
}

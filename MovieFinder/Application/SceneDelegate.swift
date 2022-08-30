//
//  SceneDelegate.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        KeychainManager.shared.deleteExistingSession()
        KeychainManager.shared.deleteAccountId()
        window = UIWindow(windowScene: windowScene)
        coordinator = AppCoordinator(window: window)
        coordinator?.start()
    }
    
//    func sceneDidDisconnect(_ scene: UIScene) {
//        print("sceneDidDisconnect")
//    }
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        print("sceneWillEnterForeground")
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        print("sceneDidBecomeActive")
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        print("sceneWillResignActive")
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        print("sceneDidEnterBackground")
//    }

}


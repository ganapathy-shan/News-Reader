//
//  SceneDelegate.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    private let coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared
    private let urlSession: URLSessionProtocol = URLSession.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Reset cache everyday to get new news content
        CacheManager.shared.coreDataManager = coreDataManager
        CacheManager.shared.resetCache()

        // Start the AppCoordinator
        let appCoordinator = AppCoordinator(window: window, coreDataManager: coreDataManager, session: urlSession)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        do {
            try coreDataManager.saveContext()
        } catch CoreDataError.saveFailed(let error) {
            // Handle the error appropriately
            print("Failed to save context: \(error.localizedDescription)")
        } catch {
            // Handle other possible errors
            print("An unexpected error occurred: \(error)")
        }
    }


}


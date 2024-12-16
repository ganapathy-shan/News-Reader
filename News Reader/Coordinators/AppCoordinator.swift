//
//  AppCoordinator.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


import UIKit

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let feedCoordinator: FeedCoordinator
    private let coreDataManager: CoreDataManagerProtocol
    private let session: URLSessionProtocol

    init(window: UIWindow, coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared, session: URLSessionProtocol = URLSession.shared) {
        self.window = window
        self.navigationController = UINavigationController()
        self.coreDataManager = coreDataManager
        self.session = session
        self.feedCoordinator = FeedCoordinator(navigationController: navigationController, coreDataManager: coreDataManager, session: session)
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        feedCoordinator.start()
    }
}

//
//  FeedCoordinator.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


import UIKit

class FeedCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let coreDataManager: CoreDataManagerProtocol
    private let session: URLSessionProtocol

    init(navigationController: UINavigationController, coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared, session: URLSessionProtocol = URLSession.shared) {
        self.navigationController = navigationController
        self.coreDataManager = coreDataManager
        self.session = session
    }

    func start() {
        let feedService = FeedService(session: session, coreDataManager: coreDataManager)  // Instantiate the service
        let feedViewModel = FeedViewModel(feedService: feedService)  // Inject into ViewModel
        let feedViewController = FeedViewController(viewModel: feedViewModel, coordinator: self)  // Inject into ViewController

        navigationController.pushViewController(feedViewController, animated: true)
    }

    // Add method to show the details screen
    func showDetail(for feedItem: FeedItem) {
        let detailViewModel = FeedDetailViewModel(feedItem: feedItem)
        let detailViewController = FeedDetailViewController(viewModel: detailViewModel)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

//
//  FeedViewController.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


import UIKit

class FeedViewController: UIViewController {
    
    weak var coordinator: FeedCoordinator?
    private let viewModel: FeedViewModel
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var feedItems : [FeedItem] = []
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // Programmatic initializer with dependency injection
    init(viewModel: FeedViewModel, coordinator: FeedCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.red]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = "My News Feed"
    }

    required init?(coder: NSCoder) {
        // Providing a default instance of FeedViewModel for storyboard compatibility
        self.viewModel = FeedViewModel(feedService: FeedService())
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return // Skip execution during unit tests
        }
        #endif
        
        setupTableView()
        setupRefreshControl()
        setupErrorLabel()
        
        Task {
            await bindViewModel()
            // Initial data fetch
            await viewModel.fetchFeed(direction: .down, useCache: true, reset: true)
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor.black : UIColor.systemGroupedBackground
        }
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }

    @objc private func refreshData() {
        Task {
            await viewModel.fetchFeed(direction: .down, useCache: false, reset: true)
        }
    }

    private func bindViewModel() async {
        await viewModel.setOnUpdate {
            [weak self] in
                Task {
                    self?.feedItems = await self?.viewModel.feedItems ?? []
                    DispatchQueue.main.async {
                        self?.errorLabel.isHidden = true
                        self?.tableView.reloadData()
                        self?.refreshControl.endRefreshing()
                    }
                }
        }
        
        await viewModel.setOnError {
            [weak self] errorMessage in
                DispatchQueue.main.async {
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = errorMessage
                    self?.refreshControl.endRefreshing()
                }
        }
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        let feedItem = feedItems[indexPath.row]
        cell.configure(with: feedItem)

        // Return the cell immediately
        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task {
            let selectedFeedItem = await viewModel.feedItems[indexPath.row]
            coordinator?.showDetail(for: selectedFeedItem)
        }
    }

    // MARK: - Pagination (Scroll Handling)

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
#if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return // Skip execution during unit tests
        }
#endif
        let threshold: CGFloat = 100.0
        let contentHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.frame.size.height
        
        if scrollOffset + scrollViewHeight >= contentHeight - threshold {
            Task {
                await viewModel.fetchFeed(direction: .down, useCache: true, reset: false)
            }
        }
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row >= feedItems.count - 3 {
                Task {
                    await viewModel.fetchFeed(direction: .down, useCache: true, reset: false)
                }
            }
        }
    }

}

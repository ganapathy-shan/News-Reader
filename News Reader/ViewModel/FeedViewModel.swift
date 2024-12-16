//
//  FeedViewModel.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//

import Foundation
import UIKit

enum ScrollDirection {
    case up
    case down
}

actor FeedViewModel {
    private let feedService: FeedServiceProtocol
    private var currentPage = 0
    private var isLoading = false

    var feedItems: [FeedItem] = []
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // New async method to safely set onUpdate from non-isolated contexts
    func setOnUpdate(_ closure: @escaping () -> Void) async {
        self.onUpdate = closure
    }
    
    func setOnError(_ closure: @escaping (String) -> Void) async {
        self.onError = closure
    }
    
    // New: Subscription-based page size
    private let freePageSize = 3
    private let subscribedPageSize = 25
    var pageSize: Int {
        return isUserSubscribed ? subscribedPageSize : freePageSize
    }
    var isUserSubscribed = false

    init(feedService: FeedServiceProtocol) {
        self.feedService = feedService
    }

    // New: Calculates articles dynamically based on screen size
    @MainActor
    private func calculateDynamicPageSize() -> Int {
        let screenHeight = UIScreen.main.bounds.height
        let estimatedCellHeight: CGFloat = 100 // Approximate height for an article cell
        return Int(ceil(screenHeight / estimatedCellHeight))
    }

    func fetchFeed(direction: ScrollDirection, useCache: Bool = true, reset: Bool = false) async {
        guard !isLoading else { return }
        
        if reset {
            currentPage = 0
            feedItems = []
        }

        // Calculate articles and pages needed
        let dynamicPageSize = await calculateDynamicPageSize()
        let articlesNeeded = max(dynamicPageSize, pageSize)
        let pagesNeeded = Int(ceil(Double(articlesNeeded) / Double(pageSize)))
        
        let startPage = direction == .down ? currentPage + 1 : currentPage - pagesNeeded
        guard startPage >= 0 else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        var fetchedItems: [FeedItem] = []
        
        if useCache {
            for page in startPage..<(startPage + pagesNeeded) {
                let cachedItems = feedService.fetchCachedFeed(page: page, pageSize: pageSize)
                fetchedItems.append(contentsOf: cachedItems)
            }
        }
        
        if fetchedItems.count < pagesNeeded * pageSize {
            let remainingPages = pagesNeeded - (fetchedItems.count / pageSize)
            do {
                for page in (currentPage + 1)...(currentPage + remainingPages) {
                    let items = try await feedService.fetchFeed(page: page, pageSize: pageSize)
                    fetchedItems.append(contentsOf: items)
                }
            } catch {
                onError?(error.localizedDescription)
                return
            }
        }
        
        // Update feed items
        updateFeedItems(fetchedItems, direction: direction)
        currentPage += (direction == .down ? pagesNeeded : -pagesNeeded)
    }

    private func updateFeedItems(_ items: [FeedItem], direction: ScrollDirection) {
        if direction == .down {
            feedItems.append(contentsOf: items)
        } else if direction == .up {
            feedItems.insert(contentsOf: items, at: 0)
        }
        onUpdate?()
    }
}

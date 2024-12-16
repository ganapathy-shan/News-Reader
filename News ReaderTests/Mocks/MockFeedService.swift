//
//  MockFeedService.swift
//  News Reader
//
//  Created by Shanmuganathan on 22/11/24.
//

@testable import News_Reader

class MockFeedService: FeedServiceProtocol {
    var feedItems: [FeedItem] = []
    var cachedFeedItems: [FeedItem] = []
    var fetchError: Error?
    var shouldFail = false

    func fetchFeed(page: Int, pageSize: Int) async throws -> [FeedItem] {
        if let error = fetchError {
            throw error
        }
        return feedItems
    }
    
    func fetchCachedFeed(page: Int, pageSize: Int) -> [FeedItem] {
        return cachedFeedItems
    }
}

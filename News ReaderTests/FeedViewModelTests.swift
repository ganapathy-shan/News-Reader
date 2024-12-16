//
//  FeedViewModelTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 22/11/24.
//


import XCTest
@testable import News_Reader

final class FeedViewModelTests: XCTestCase {
    private var feedViewModel: FeedViewModel!
    private var mockFeedService: MockFeedService!

    override func setUp() {
        super.setUp()
        mockFeedService = MockFeedService()
        feedViewModel = FeedViewModel(feedService: mockFeedService)
    }

    override func tearDown() {
        feedViewModel = nil
        mockFeedService = nil
        super.tearDown()
    }

    // MARK: - Test: Fetch feed with scrolling down

    func testFetchFeed_Down() async {
        // Arrange
        let feedItem1 = FeedItem(uuid: "1", title: "Title 1", description: nil, keywords: nil, snippet: nil, link: "http://example.com", imageUrl: nil, language: nil, publishDate: "2024-12-01", source: "Source", categories: nil, relevanceScore: nil, locale: "en")
        let feedItem2 = FeedItem(uuid: "2", title: "Title 2", description: nil, keywords: nil, snippet: nil, link: "http://example.com", imageUrl: nil, language: nil, publishDate: "2024-12-02", source: "Source", categories: nil, relevanceScore: nil, locale: "en")
        mockFeedService.feedItems = [feedItem1, feedItem2]

        let expectation = expectation(description: "onUpdate called")
        await feedViewModel.setOnUpdate {
            expectation.fulfill()
        }

        // Act
        await feedViewModel.fetchFeed(direction: .down, useCache: false)

        // Assert
        let feedItems = await feedViewModel.feedItems
        let pageSize = await feedViewModel.pageSize
        XCTAssertEqual(feedItems.count, 2*pageSize)
        XCTAssertEqual(feedItems.first?.title, "Title 1")
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Test: Fetch feed with caching enabled

    func testFetchFeed_WithCache() async {
        // Arrange
        let cachedFeedItem = FeedItem(uuid: "3", title: "Cached Title", description: nil, keywords: nil, snippet: nil, link: "http://example.com", imageUrl: nil, language: nil, publishDate: "2024-12-01", source: "Cached Source", categories: nil, relevanceScore: nil, locale: "en")
        mockFeedService.cachedFeedItems = [cachedFeedItem]

        let expectation = expectation(description: "onUpdate called")
        await feedViewModel.setOnUpdate {
            expectation.fulfill()
        }

        // Act
        await feedViewModel.fetchFeed(direction: .down, useCache: true)

        // Assert
        let feedItems = await feedViewModel.feedItems
        let pageSize = await feedViewModel.pageSize
        XCTAssertEqual(feedItems.count, 1*pageSize)
        XCTAssertEqual(feedItems.first?.title, "Cached Title")
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Test: Fetch feed with error handling

    func testFetchFeed_Error() async {
        // Arrange
        let errorMessage = "Network Error"
        mockFeedService.fetchError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])

        let expectation = expectation(description: "onError called")
        await feedViewModel.setOnError { error in
            XCTAssertEqual(error, errorMessage)
            expectation.fulfill()
        }

        // Act
        await feedViewModel.fetchFeed(direction: .down, useCache: false)

        // Assert
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Test: Reset pagination and feed items

    func testFetchFeed_WithReset() async {
        // Arrange
        let initialFeedItem = FeedItem(uuid: "4", title: "Old Feed", description: nil, keywords: nil, snippet: nil, link: "http://example.com", imageUrl: nil, language: nil, publishDate: "2024-12-01", source: "Source", categories: nil, relevanceScore: nil, locale: "en")
        let newFeedItem = FeedItem(uuid: "5", title: "New Feed", description: nil, keywords: nil, snippet: nil, link: "http://example.com", imageUrl: nil, language: nil, publishDate: "2024-12-02", source: "Source", categories: nil, relevanceScore: nil, locale: "en")

        mockFeedService.feedItems = [initialFeedItem]
        await feedViewModel.fetchFeed(direction: .down, useCache: false)

        mockFeedService.feedItems = [newFeedItem]

        let expectation = expectation(description: "onUpdate called after reset")
        await feedViewModel.setOnUpdate {
            expectation.fulfill()
        }

        // Act
        await feedViewModel.fetchFeed(direction: .down, useCache: false, reset: true)

        // Assert
        let feedItems = await feedViewModel.feedItems
        let pageSize = await feedViewModel.pageSize
        XCTAssertEqual(feedItems.count, 1*pageSize)
        XCTAssertEqual(feedItems.first?.title, "New Feed")
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

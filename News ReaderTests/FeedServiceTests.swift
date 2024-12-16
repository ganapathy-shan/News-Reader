//
//  FeedServiceTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 21/11/24.
//


import XCTest
@testable import News_Reader
import CoreData
import Foundation

class FeedServiceTests: XCTestCase {

    var feedService: FeedService!
    var mockCoreDataManager: CoreDataManagerMock!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        
        // Initialize mocks
        mockCoreDataManager = CoreDataManagerMock()
        mockSession = MockURLSession(data: nil, response: nil, error: nil) // Initialize with default values
        
        // Initialize FeedService with mocked dependencies
        feedService = FeedService(session: mockSession, coreDataManager: mockCoreDataManager)
    }

    override func tearDown() {
        feedService = nil
        mockCoreDataManager = nil
        mockSession = nil
        super.tearDown()
    }

    // Test: Successful fetchFeed with valid data
    func testFetchFeed_Success() async throws {
        let mockData = """
        {
            "meta": {
                "found": 1151755,
                "returned": 10,
                "limit": 10,
                "page": 1
            },
            "data": [
                {
                    "uuid": "1",
                    "title": "Title 1",
                    "description": "Description 1",
                    "keywords": "keyword1",
                    "snippet": "Snippet 1",
                    "url": "https://example.com",
                    "image_url": "https://example.com/image.jpg",
                    "language": "en",
                    "published_at": "2024-11-21T00:00:00Z",
                    "source": "Source 1",
                    "categories": ["Category1"],
                    "relevance_score": "0.9",
                    "locale": "us"
                }
            ]
        }
        """
        
        // Ensure that mockData is properly converted to Data
        guard let mockData = mockData.data(using: .utf8) else {
            XCTFail("Failed to convert mockData to Data")
            return
        }

        mockSession = MockURLSession(data: mockData, response: nil, error: nil)
        // Reinitialize feedService with the updated mockSession
        feedService = FeedService(session: mockSession, coreDataManager: mockCoreDataManager)

        do {
            let feedItems = try await feedService.fetchFeed(page: 1, pageSize: 10)
            XCTAssertEqual(feedItems.count, 1)
            XCTAssertEqual(feedItems[0].title, "Title 1")
        } catch {
            XCTFail("Expected success, but got error: \(error)")
        }
    }



    // Test: fetchFeed with invalid URL
    func testFetchFeed_InvalidURL() async {
        let invalidFeedService = FeedServiceMockInvalidURL()

        do {
            _ = try await invalidFeedService.fetchFeed(page: 1, pageSize: 10)
            XCTFail("Expected an error to be thrown, but succeeded")
        } catch let error as NSError {
            XCTAssertEqual(error, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // Test: fetchFeed with API error response
    func testFetchFeed_APIError() async {
        let mockData = """
        {
            "error": {
                "code": "invalid_api_token",
                "message": "An invalid API token was supplied."
            }
        }
        """
        mockSession = MockURLSession(data: mockData.data(using: .utf8), response: nil, error: nil)
        
        // Reinitialize feedService with the updated mockSession
        feedService = FeedService(session: mockSession, coreDataManager: mockCoreDataManager)

        do {
            _ = try await feedService.fetchFeed(page: 1, pageSize: 10)
            XCTFail("Expected error, but succeeded")
        } catch let error as APIError {
            XCTAssertEqual(error.message, "An invalid API token was supplied.")
        } catch {
            XCTFail("Expected APIError, but got error: \(error)")
        }
    }



    // Test: saveToCache - Check if core data save works correctly
    func testSaveToCache() {
        // Create a FeedItem object
        let feedItem = FeedItem(
            uuid: "1",
            title: "Title 1",
            description: "Description",
            keywords: "Keyword",
            snippet: "Snippet",
            link: "https://example.com",
            imageUrl: "https://example.com/image.jpg",
            language: "en",
            publishDate: "2024-11-21T00:00:00Z", // String publishDate
            source: "Source",
            categories: ["Category"], // Array of strings for categories
            relevanceScore: "0.9", // String relevanceScore
            locale: "us"
        )
        // Save the FeedItem object to the cache
        feedService.saveToCache([feedItem])

        // Fetch the cached items from the Core Data mock context
        let context = mockCoreDataManager.context
        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()

        do {
            let cachedItems = try context.fetch(fetchRequest)

            XCTAssertEqual(cachedItems.count, 1) // Verify one item was saved

            let cachedItem = cachedItems[0]

            XCTAssertEqual(cachedItem.uuid, "1")
            XCTAssertEqual(cachedItem.title, "Title 1")
            XCTAssertEqual(cachedItem.descriptionText, "Description")
            XCTAssertEqual(cachedItem.keywords, "Keyword")
            XCTAssertEqual(cachedItem.snippet, "Snippet")
            XCTAssertEqual(cachedItem.link, "https://example.com")
            XCTAssertEqual(cachedItem.imageUrl, "https://example.com/image.jpg")
            XCTAssertEqual(cachedItem.language, "en")
            XCTAssertEqual(cachedItem.publishDate, "2024-11-21T00:00:00Z") // Verify String publishDate
            XCTAssertEqual(cachedItem.source, "Source")
            XCTAssertEqual(cachedItem.categories, "Category") // Verify serialized categories
            XCTAssertEqual(cachedItem.relevanceScore, "0.9") // Verify String relevanceScore
        } catch {
            XCTFail("Failed to fetch cached items: \(error)")
        }
    }



    // Test: fetchCachedFeed - Check if cached data is fetched correctly
    func testFetchCachedFeed_Success() {
        // Create mock CachedFeedItem
        let cachedItem = CachedFeedItem(context: mockCoreDataManager.context)
        cachedItem.uuid = "1"
        cachedItem.title = "Title 1"
        cachedItem.descriptionText = "Description"
        cachedItem.link = "https://example.com"
        cachedItem.imageUrl = "https://example.com/image.jpg"
        cachedItem.language = "en"
        cachedItem.publishDate = "2024-11-21T00:00:00Z" // String publishDate
        cachedItem.source = "Source"
        cachedItem.categories = "Category1"
        cachedItem.relevanceScore = "0.9"
        
        mockCoreDataManager.addMockCache([cachedItem])

        let fetchedItems = feedService.fetchCachedFeed(page: 1, pageSize: 10)

        XCTAssertEqual(fetchedItems.count, 1)
        XCTAssertEqual(fetchedItems[0].title, "Title 1")
    }

    // Test: fetchCachedFeed - Empty result when no items are cached
    func testFetchCachedFeed_Empty() {
        let fetchedItems = feedService.fetchCachedFeed(page: 1, pageSize: 10)
        XCTAssertTrue(fetchedItems.isEmpty)
    }
}


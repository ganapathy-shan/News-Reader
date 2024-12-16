//
//  FeedDetailViewModelTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 05/12/24.
//


import XCTest
import SDWebImage
@testable import News_Reader

final class FeedDetailViewModelTests: XCTestCase {
    private var feedItem: FeedItem!
    private var viewModel: FeedDetailViewModel!

    override func setUp() {
        super.setUp()
        // Create a sample FeedItem for testing
        feedItem = FeedItem(
            uuid: "1",
            title: "Test Title",
            description: "Test Description",
            keywords: nil,
            snippet: nil,
            link: "http://example.com/article",
            imageUrl: "http://example.com/image.jpg",
            language: "en",
            publishDate: "2024-12-05",
            source: "Test Source",
            categories: ["Tech", "News"],
            relevanceScore: nil,
            locale: "en"
        )
        viewModel = FeedDetailViewModel(feedItem: feedItem)
    }

    override func tearDown() {
        viewModel = nil
        feedItem = nil
        super.tearDown()
    }

    // MARK: - Test Exposed Properties

    func testTitle() {
        XCTAssertEqual(viewModel.title, feedItem.title, "Title should match the feed item's title.")
    }

    func testDescription() {
        XCTAssertEqual(viewModel.description, feedItem.description, "Description should match the feed item's description.")
    }

    func testImageUrl() {
        XCTAssertEqual(viewModel.imageUrl, feedItem.imageUrl, "Image URL should match the feed item's image URL.")
    }

    func testPublishedDate() {
        XCTAssertEqual(viewModel.publishedDate, feedItem.publishDate, "Published date should match the feed item's publish date.")
    }

    func testSource() {
        XCTAssertEqual(viewModel.source, feedItem.source, "Source should match the feed item's source.")
    }

    func testArticleUrl() {
        XCTAssertEqual(viewModel.articleUrl, URL(string: feedItem.link), "Article URL should match the feed item's link as a URL.")
    }

    func testCategories() {
        XCTAssertEqual(viewModel.categories, feedItem.categories, "Categories should match the feed item's categories.")
    }

    func testLoadImage_InvalidUrl() {
        let imageView = UIImageView()
        feedItem = FeedItem(
            uuid: "1",
            title: "Test Title",
            description: nil,
            keywords: nil,
            snippet: nil,
            link: "http://example.com/article",
            imageUrl: "invalid_url",
            language: nil,
            publishDate: "2024-12-05",
            source: nil,
            categories: nil,
            relevanceScore: nil,
            locale: nil
        )
        viewModel = FeedDetailViewModel(feedItem: feedItem)

        viewModel.loadImage(into: imageView)
        XCTAssertNil(imageView.image, "Image should be nil for an invalid URL.")
    }

    func testLoadImage_NoUrl() {
        let imageView = UIImageView()
        feedItem = FeedItem(
            uuid: "1",
            title: "Test Title",
            description: nil,
            keywords: nil,
            snippet: nil,
            link: "http://example.com/article",
            imageUrl: nil,
            language: nil,
            publishDate: "2024-12-05",
            source: nil,
            categories: nil,
            relevanceScore: nil,
            locale: nil
        )
        viewModel = FeedDetailViewModel(feedItem: feedItem)

        viewModel.loadImage(into: imageView)
        XCTAssertNil(imageView.image, "Image should be nil when there is no URL.")
    }
}

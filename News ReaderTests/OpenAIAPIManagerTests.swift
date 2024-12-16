//
//  OpenAIAPIManagerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

import XCTest
@testable import News_Reader

final class OpenAIAPIManagerTests: XCTestCase {
    var apiManager: OpenAIAPIManager!
    var mockExtractor: MockWebContentExtractor!
    var mockCacheManager: MockSummaryCacheManager!

    override func setUp() {
        super.setUp()
        mockExtractor = MockWebContentExtractor()
        mockCacheManager = MockSummaryCacheManager()
        apiManager = OpenAIAPIManager(webContentExtractor: mockExtractor, summaryCacheManager: mockCacheManager)
    }

    func testSummarizeURLFromCache() {
        let url = "https://example.com"
        let cachedSummary = "Cached summary"
        mockCacheManager.cacheSummary(cachedSummary, forURL: url)

        let expectation = self.expectation(description: "Summary should be fetched from cache")

        apiManager.summarizeURL(url: url) { result in
            switch result {
            case .success(let summary):
                XCTAssertEqual(summary, cachedSummary, "Summary should match the cached summary.")
                expectation.fulfill()
            case .failure:
                XCTFail("Summary fetch should not fail.")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSummarizeURLFromExtractor() async throws {
        // Test URL and mock responses
        let url = "https://example.com"
        let mockContent = "Mock content"
        let mockSummary = "Mock summary"
        
        // Mock OpenAI API response
        let mockAPIResponse = """
        {
            "choices": [{
                "message": {
                    "content": "\(mockSummary)"
                }
            }]
        }
        """.data(using: .utf8)
        
        // Setup mock components
        let mockExtractor = MockWebContentExtractor()
        mockExtractor.mockContent = mockContent
        mockExtractor.shouldSucceed = true
        
        let mockCacheManager = MockSummaryCacheManager()
        
        let mockSession = MockURLSession(data: mockAPIResponse, response: nil, error: nil)
        
        let apiManager = OpenAIAPIManager(webContentExtractor: mockExtractor,
                                          summaryCacheManager: mockCacheManager,
                                          session: mockSession)
        
        // Expectation for async testing
        let expectation = XCTestExpectation(description: "Summary should be fetched, cached, and match the mock data")
        
        // Call the method under test
        apiManager.summarize(text: mockContent, url: url) { result in
            switch result {
            case .success(let summary):
                XCTAssertFalse(summary.isEmpty, "Summary should not be empty.")
                XCTAssertEqual(summary, mockSummary, "Summary should match the mocked API response.")
                XCTAssertEqual(mockCacheManager.getCachedSummary(forURL: url), summary, "Summary should be cached.")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Summary fetch failed with error: \(error)")
            }
        }
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 5.0)
    }

    func testSummarizeURLExtractorFailure() {
        let url = "https://example.com"
        mockExtractor.shouldSucceed = false
        mockExtractor.mockError = NSError(domain: "MockWebContentExtractor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock failure"])

        let expectation = self.expectation(description: "Summary fetch should fail")

        apiManager.summarizeURL(url: url) { result in
            switch result {
            case .success:
                XCTFail("Summary fetch should fail.")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Mock failure", "Error should match the mock error.")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}

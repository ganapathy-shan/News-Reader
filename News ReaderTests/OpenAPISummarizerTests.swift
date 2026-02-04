//
//  OpenAPISummarizerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 04/02/26.
//

import XCTest
@testable import News_Reader

final class OpenAPISummarizerTests: XCTestCase {
    func testSummarizeURLFromCache() {
        let url = "https://example.com"
        let cachedSummary = "Cached summary"
        let mockExtractor = MockWebContentExtractor()
        let mockCacheManager = MockSummaryCacheManager()
        mockCacheManager.cacheSummary(cachedSummary, forURL: url)

        let summarizer = OpenAPISummarizer(webContentExtractor: mockExtractor,
                                           summaryCacheManager: mockCacheManager,
                                           session: MockURLSession(data: nil, response: nil, error: nil),
                                           apiKey: "test-key")

        let expectation = self.expectation(description: "Summary should be fetched from cache")

        summarizer.summarizeURL(url: url) { result in
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

    func testSummarizeURLFromExtractor() {
        let url = "https://example.com"
        let mockContent = "Mock content"
        let mockSummary = "Mock summary"

        let mockAPIResponse = """
        {
            "choices": [{
                "message": {
                    "content": "\(mockSummary)"
                }
            }]
        }
        """.data(using: .utf8)

        let mockExtractor = MockWebContentExtractor()
        mockExtractor.mockContent = mockContent
        mockExtractor.shouldSucceed = true

        let mockCacheManager = MockSummaryCacheManager()
        let mockSession = MockURLSession(data: mockAPIResponse, response: nil, error: nil)

        let summarizer = OpenAPISummarizer(webContentExtractor: mockExtractor,
                                           summaryCacheManager: mockCacheManager,
                                           session: mockSession,
                                           apiKey: "test-key")

        let expectation = XCTestExpectation(description: "Summary should be fetched, cached, and match the mock data")

        summarizer.summarize(text: mockContent, url: url) { result in
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

        wait(for: [expectation], timeout: 5.0)
    }

    func testSummarizeURLExtractorFailure() {
        let url = "https://example.com"
        let mockExtractor = MockWebContentExtractor()
        mockExtractor.shouldSucceed = false
        mockExtractor.mockError = NSError(domain: "MockWebContentExtractor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock failure"])

        let summarizer = OpenAPISummarizer(webContentExtractor: mockExtractor,
                                           summaryCacheManager: MockSummaryCacheManager(),
                                           session: MockURLSession(data: nil, response: nil, error: nil),
                                           apiKey: "test-key")

        let expectation = self.expectation(description: "Summary fetch should fail")

        summarizer.summarizeURL(url: url) { result in
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

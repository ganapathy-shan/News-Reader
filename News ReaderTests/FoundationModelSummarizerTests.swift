//
//  FoundationModelSummarizerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 04/02/26.
//

import XCTest
@testable import News_Reader

final class FoundationModelSummarizerTests: XCTestCase {
    private var summarizer: FoundationModelSummarizer!
    private var mockExtractor: MockWebContentExtractor!
    private var mockCacheManager: MockSummaryCacheManager!
    private var mockSummaryGenerator: MockSummaryGenerator!

    override func setUp() {
        super.setUp()
        mockExtractor = MockWebContentExtractor()
        mockCacheManager = MockSummaryCacheManager()
        mockSummaryGenerator = MockSummaryGenerator()
        summarizer = FoundationModelSummarizer(
            webContentExtractor: mockExtractor,
            summaryCacheManager: mockCacheManager,
            summaryGenerator: mockSummaryGenerator
        )
    }

    func testSummarizeURLFromCacheSkipsExtractor() {
        let url = "https://example.com"
        let cachedSummary = "Cached summary"
        mockCacheManager.cacheSummary(cachedSummary, forURL: url)
        mockExtractor.shouldSucceed = false

        let expectation = self.expectation(description: "Summary should be fetched from cache")

        summarizer.summarizeURL(url: url) { result in
            switch result {
            case .success(let summary):
                XCTAssertEqual(summary, cachedSummary, "Summary should match the cached summary.")
                expectation.fulfill()
            case .failure:
                XCTFail("Summary fetch should not fail when cached.")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSummarizeTextCachesSummary() {
        let url = "https://example.com"
        let mockContent = "Mock content"
        let mockSummary = "Mock summary"
        mockSummaryGenerator.summary = mockSummary

        let expectation = self.expectation(description: "Summary should be generated and cached")

        summarizer.summarize(text: mockContent, url: url) { result in
            switch result {
            case .success(let summary):
                XCTAssertEqual(summary, mockSummary, "Summary should match the generated summary.")
                XCTAssertEqual(self.mockCacheManager.getCachedSummary(forURL: url), mockSummary, "Summary should be cached.")
                XCTAssertEqual(self.mockSummaryGenerator.lastText, mockContent, "Generator should be called with the content.")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Summary generation failed with error: \(error)")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSummarizeURLExtractorFailure() {
        let url = "https://example.com"
        mockExtractor.shouldSucceed = false
        mockExtractor.mockError = NSError(domain: "MockWebContentExtractor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock failure"])

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

private final class MockSummaryGenerator: SummaryGeneratorProtocol {
    var summary = "Mock summary"
    var shouldFail = false
    var lastText: String?

    func generateSummary(from text: String) async throws -> String {
        lastText = text
        if shouldFail {
            throw NSError(domain: "MockSummaryGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock failure"])
        }
        return summary
    }
}

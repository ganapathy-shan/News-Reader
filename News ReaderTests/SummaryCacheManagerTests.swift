//
//  SummaryCacheManagerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//


import XCTest
@testable import News_Reader

final class SummaryCacheManagerTests: XCTestCase {
    var cacheManager: SummaryCacheManagerProtocol!

    override func setUp() {
        super.setUp()
        cacheManager = SummaryCacheManager.shared
    }

    func testCacheSummary() {
        let url = "https://example.com/article"
        let summary = "This is a summary of the article."

        cacheManager.cacheSummary(summary, forURL: url)
        XCTAssertEqual(cacheManager.getCachedSummary(forURL: url), summary, "The cached summary should match the input.")
    }

    func testGetCachedSummary() {
        cacheManager.clearCache()
        let url = "https://example.com/article"
        XCTAssertNil(cacheManager.getCachedSummary(forURL: url), "Cache should return nil for uncached URLs.")

        let summary = "Cached summary"
        cacheManager.cacheSummary(summary, forURL: url)
        XCTAssertEqual(cacheManager.getCachedSummary(forURL: url), summary, "Cache should return the correct summary.")
    }
}

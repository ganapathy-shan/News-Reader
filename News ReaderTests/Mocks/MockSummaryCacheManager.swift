//
//  MockSummaryCacheManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

@testable import News_Reader

class MockSummaryCacheManager: SummaryCacheManagerProtocol {
    
    private var cache: [String: String] = [:]

    func getCachedSummary(forURL url: String) -> String? {
        return cache[url]
    }

    func cacheSummary(_ summary: String, forURL url: String) {
        cache[url] = summary
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

//
//  SummaryCacheManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 14/12/24.
//


import Foundation

protocol SummaryCacheManagerProtocol {
    func getCachedSummary(forURL url: String) -> String?
    func cacheSummary(_ summary: String, forURL url: String)
    func clearCache()
}

class SummaryCacheManager : SummaryCacheManagerProtocol {
    static let shared = SummaryCacheManager()
    private let cache = NSCache<NSString, NSString>()

    private init() {}

    func getCachedSummary(forURL url: String) -> String? {
        return cache.object(forKey: url as NSString) as String?
    }

    func cacheSummary(_ summary: String, forURL url: String) {
        cache.setObject(summary as NSString, forKey: url as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

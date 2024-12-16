//
//  FeedService.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//

import Foundation
import CoreData

protocol FeedServiceProtocol {
    func fetchFeed(page: Int, pageSize: Int) async throws -> [FeedItem]
    func fetchCachedFeed(page: Int, pageSize: Int) -> [FeedItem]
}

class FeedService: FeedServiceProtocol {
    
    private let apiURL = "https://api.thenewsapi.com/v1/news/top"
    private var apiKey = ""
    
    private var session: URLSessionProtocol
    private var coreDataManager: CoreDataManagerProtocol
    
    // Dependency Injection via initializer
    init(session: URLSessionProtocol = URLSession.shared, coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.session = session
        self.coreDataManager = coreDataManager
        if let key = ApiKeyManager.shared.getApiKey(for: "NewsAPIKey") {
            apiKey = key
        }
    }
    
    func fetchFeed(page: Int, pageSize: Int) async throws -> [FeedItem] {
        
        guard !apiKey.isEmpty else {
            throw NSError(domain: "Invalid API Key", code: 410, userInfo: nil)
        }
        
        
        // Build the URL with pagination and API key
        let urlString = "\(apiURL)?api_token=\(apiKey)&locale=us&page=\(page)&limit=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        let (data, _) = try await session.data(from: url)

        // Attempt to decode an error response first
        if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
            throw apiError
        }

        // Decode the successful response as FeedResponse
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let feedResponse = try decoder.decode(FeedResponse.self, from: data)
        
        saveToCache(feedResponse.data)
        return feedResponse.data
    }
    
    func saveToCache(_ feedItems: [FeedItem]) {
        let context = coreDataManager.context
        
        // Fetch existing CachedFeedItems to avoid modifying while iterating
        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        var existingItems: [CachedFeedItem] = []
        
        do {
            existingItems = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch existing cached items: \(error)")
        }
        
        // Create a set of existing UUIDs to check if the item is already cached
        let existingUUIDs = Set(existingItems.map { $0.uuid ?? "" })
        
        feedItems.forEach { item in
            // Only add items that are not already cached
            if !existingUUIDs.contains(item.uuid) {
                let cachedItem = CachedFeedItem(context: context)
                cachedItem.uuid = item.uuid
                cachedItem.title = item.title
                cachedItem.descriptionText = item.description ?? ""
                cachedItem.keywords = item.keywords ?? ""
                cachedItem.snippet = item.snippet ?? ""
                cachedItem.link = item.link
                cachedItem.imageUrl = item.imageUrl ?? ""
                cachedItem.language = item.language ?? ""
                cachedItem.publishDate = item.publishDate
                cachedItem.source = item.source ?? ""
                cachedItem.categories = item.categories?.joined(separator: ",")
                cachedItem.relevanceScore = item.relevanceScore ?? ""
            }
        }
        
        // Save context after the loop completes
        do {
            try coreDataManager.saveContext()
        } catch CoreDataError.saveFailed(let error) {
            // Handle the error appropriately
            print("Failed to save context: \(error.localizedDescription)")
        } catch {
            // Handle other possible errors
            print("An unexpected error occurred: \(error)")
        }
    }


    func fetchCachedFeed(page: Int, pageSize: Int) -> [FeedItem] {
        let request: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        request.fetchLimit = pageSize
        request.fetchOffset = (page - 1) * pageSize
        
        do {
            let cachedItems = try coreDataManager.fetch(request)
            return cachedItems.map { cachedItem in
                FeedItem(
                    uuid: cachedItem.uuid ?? "",
                    title: cachedItem.title ?? "",
                    description: cachedItem.descriptionText,
                    keywords: cachedItem.keywords,
                    snippet: cachedItem.snippet,
                    link: cachedItem.link!,
                    imageUrl: cachedItem.imageUrl,
                    language: cachedItem.language,
                    publishDate: cachedItem.publishDate!,
                    source: cachedItem.source,
                    categories: cachedItem.categories?.components(separatedBy: ","),
                    relevanceScore: cachedItem.relevanceScore,
                    locale: "us"
                )
            }
        } catch {
            print("Failed to fetch cached items:", error)
            return []
        }
    }

}


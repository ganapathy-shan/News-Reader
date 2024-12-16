//
//  FeedServiceMockInvalidURL.swift
//  News Reader
//
//  Created by Shanmuganathan on 21/11/24.
//

@testable import News_Reader
import Foundation

class FeedServiceMockInvalidURL: FeedService {
    override func fetchFeed(page: Int, pageSize: Int) async throws -> [FeedItem] {
        throw NSError(domain: "Invalid URL", code: 400, userInfo: [:])
    }
}

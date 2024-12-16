//
//  FeedItem.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//

import Foundation

struct FeedItem: Codable {
    let uuid: String
    let title: String
    let description: String?
    let keywords: String?
    let snippet: String?
    let link: String
    let imageUrl: String?
    let language: String?
    let publishDate: String
    let source: String?
    let categories: [String]?
    let relevanceScore: String?
    let locale: String?

    enum CodingKeys: String, CodingKey {
        case uuid
        case title
        case description
        case keywords
        case snippet
        case link = "url"
        case imageUrl = "image_url"
        case language
        case publishDate = "published_at"
        case source
        case categories
        case relevanceScore = "relevance_score"
        case locale
    }
}


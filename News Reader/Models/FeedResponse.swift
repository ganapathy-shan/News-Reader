//
//  FeedResponse.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//

// FeedResponse Model for the entire API Response
struct FeedResponse: Codable {
    let meta: MetaData
    let data: [FeedItem]
}

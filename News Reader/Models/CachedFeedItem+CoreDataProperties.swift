//
//  CachedFeedItem+CoreDataProperties.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//
//

import Foundation
import CoreData


extension CachedFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedFeedItem> {
        return NSFetchRequest<CachedFeedItem>(entityName: "CachedFeedItem")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var title: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var keywords: String?
    @NSManaged public var snippet: String?
    @NSManaged public var link: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var language: String?
    @NSManaged public var publishDate: String?
    @NSManaged public var source: String?
    @NSManaged public var categories: String?
    @NSManaged public var relevanceScore: String?

}

extension CachedFeedItem : Identifiable {

}

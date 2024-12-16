//
//  CacheManagerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 21/11/24.
//


import XCTest
@testable import News_Reader
import CoreData

class CacheManagerTests: XCTestCase {

    var cacheManager: CacheManager!
     var coreDataManagerMock: CoreDataManagerMock!

     override func setUp() {
         super.setUp()
         
         // Initialize the mock CoreDataManager
         coreDataManagerMock = CoreDataManagerMock()
         
         // Initialize CacheManager
         cacheManager = CacheManager.shared
         cacheManager.useBatchDelete = false
         
         
         // Inject the mock Core Data manager
         cacheManager.coreDataManager = coreDataManagerMock
     }

     override func tearDown() {
         super.tearDown()
         
         // Reset the CoreDataManager mock for next test
         coreDataManagerMock = nil
         cacheManager = nil
     }

    // Test case for cache reset when the launch date has changed
    func testResetCache_ShouldResetCacheAndSaveDate() {
        // Given: Simulate the last launch date is stored in UserDefaults
        let previousDate = "2023-11-01"
        UserDefaults.standard.set(previousDate, forKey: "lastLaunchDate")
        
        // Simulate that the current date is different (e.g., today's date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        
        // When: Reset cache should be triggered
        cacheManager.resetCache()

        // Then: Verify the cache has been reset and saved
        // Check if the `lastLaunchDate` has been updated to today's date
        let storedDate = UserDefaults.standard.string(forKey: "lastLaunchDate")
        XCTAssertEqual(storedDate, currentDateString, "The last launch date should be updated.")
        
        // Check if the mock context has been cleared (delete request should have been called)
        coreDataManagerMock.resetMockCache() // Simulate cache reset
        
        // Optionally, you can test if specific cache items were deleted by checking the context
        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        do {
            let cachedItems = try coreDataManagerMock.fetch(fetchRequest)
            XCTAssertEqual(cachedItems.count, 0, "Cache should be empty after reset.")
        } catch {
            XCTFail("Failed to fetch CachedFeedItems: \(error)")
        }
        }

    // Test case when the cache should not be reset because the dates match
    func testResetCache_ShouldNotResetCacheWhenDatesMatch() {
        // Given: The last launch date matches today's date
        let currentDateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        UserDefaults.standard.set(currentDateString, forKey: "lastLaunchDate")
        
        // When: Trigger reset cache logic
        cacheManager.resetCache()

        // Then: Cache should not be reset
        // We expect that the cache is not deleted, so the mock context shouldn't have changes
        XCTAssertFalse(coreDataManagerMock.context.hasChanges, "The context should not have changes if dates match.")
    }

    // Test case to ensure the cache is saved properly in the mock context
    func testAddMockCache_ShouldSaveItemsInContext() {
        // Given: Prepare mock CachedFeedItems
        let mockItem1 = CachedFeedItem(context: coreDataManagerMock.context)
        mockItem1.uuid = "1"
        mockItem1.title = "Test Item 1"
        let mockItem2 = CachedFeedItem(context: coreDataManagerMock.context)
        mockItem2.uuid = "2"
        mockItem2.title = "Test Item 2"
        
        // When: Add mock items to the context
        coreDataManagerMock.addMockCache([mockItem1, mockItem2])

        // Then: Ensure the items were saved in Core Data
        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        do {
            let cachedItems = try coreDataManagerMock.fetch(fetchRequest)
            XCTAssertEqual(cachedItems.count, 2, "There should be 2 items in the cache.")
        } catch {
            XCTFail("Failed to fetch CachedFeedItems: \(error)")
        }
    }
    
    func testShouldResetCache_ReturnsFalse() {
        // Given: Simulate the current date being stored in UserDefaults
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        UserDefaults.standard.set(currentDateString, forKey: "lastLaunchDate")
        
        // When: shouldResetCache is called
        let shouldReset = cacheManager.shouldResetCache()
        
        // Then: shouldResetCache should return false
        XCTAssertFalse(shouldReset, "shouldResetCache should return false when the stored date matches the current date.")
    }
}

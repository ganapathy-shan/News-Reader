//
//  CoreDataManagerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 22/11/24.
//

@testable import News_Reader
import XCTest
import CoreData

final class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()

        // Setup in-memory persistent container for testing
        let modelURL = Bundle(for: type(of: self)).url(forResource: "Mock_News_Reader", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        let persistentContainer = NSPersistentContainer(name: "Mock_News_Reader", managedObjectModel: managedObjectModel)

        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [storeDescription]

        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory store: \(error!)")
        }

        // Initialize CoreDataManager with the test container
        coreDataManager = CoreDataManager(persistentContainer: persistentContainer)
    }

    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }

    func testSaveContext_Success() {
        let context = coreDataManager.context
        let feedItem = CachedFeedItem(context: context)
        feedItem.uuid = "1"
        feedItem.title = "Test Title"
        feedItem.link = "https://example.com" // Required field
        feedItem.publishDate = "2024-11-22T12:00:00Z" // Required field

        do {
            try coreDataManager.saveContext()  // Now `saveContext` throws an error
        } catch {
            XCTFail("Failed to save context: \(error)")
            return
        }

        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        do {
            let fetchedItems = try coreDataManager.fetch(fetchRequest)
            XCTAssertEqual(fetchedItems.count, 1)
            XCTAssertEqual(fetchedItems.first?.uuid, "1")
        } catch {
            XCTFail("Failed to fetch saved item: \(error)")
        }
    }

    func testSaveContext_Failure() {
        // Given: A CoreDataManager with a MockPersistentContainer
        let modelURL = Bundle(for: type(of: self)).url(forResource: "Mock_News_Reader", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let mockContainer = MockPersistentContainer(name: "Mock_News_Reader", managedObjectModel: model)

        // Inject the mock failing context into CoreDataManager
        let coreDataManager = CoreDataManager(persistentContainer: mockContainer)

        // Create a new feed item, which will modify the context to have changes
        let feedItem = CachedFeedItem(context: coreDataManager.context)
        feedItem.uuid = "1"
        feedItem.title = "Test Feed Item"
        
        // Ensure that there are changes in the context
        XCTAssertTrue(coreDataManager.context.hasChanges)

        // When: Attempt to save the context, which should fail
        do {
            // Trying to save should throw an error due to the mock failing context
            try coreDataManager.saveContext()
            
            // If save didn't fail, we expect the error to be thrown
            XCTFail("Expected saveContext to throw an error, but it did not.")
        } catch let error as CoreDataError {
            // Then: Ensure the error is of the saveFailed type
            switch error {
            case .saveFailed(let underlyingError):
                // Check the error message
                XCTAssertEqual(underlyingError.localizedDescription, "Failed to save context")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetch_Success() {
        let context = coreDataManager.context
        let feedItem = CachedFeedItem(context: context)
        feedItem.uuid = "2"
        feedItem.title = "Another Test Title"
        feedItem.link = "https://example.com" // Required field
        feedItem.publishDate = "2024-11-22T12:00:00Z" // Required field

        do {
            try coreDataManager.saveContext()
        } catch {
            XCTFail("Failed to save context: \(error)")
            return
        }

        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        do {
            let fetchedItems = try coreDataManager.fetch(fetchRequest)
            XCTAssertEqual(fetchedItems.count, 1)
            XCTAssertEqual(fetchedItems.first?.uuid, "2")
        } catch {
            XCTFail("Failed to fetch items: \(error)")
        }
    }

}

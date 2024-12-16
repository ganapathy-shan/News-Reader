//
//  CoreDataManagerMock.swift
//  News Reader
//
//  Created by Shanmuganathan on 21/11/24.
//

@testable import News_Reader
import CoreData

class CoreDataManagerMock: CoreDataManagerProtocol {
    var context: NSManagedObjectContext
    private var mockCache: [CachedFeedItem] = []

    init() {
        // Load the Core Data model
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "Mock_News_Reader", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model")
        }

        // Create an in-memory persistent container
        let persistentContainer = NSPersistentContainer(name: "Mock_News_Reader", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Failed to load in-memory persistent store: \(error)")
            }
        }

        // Set the context
        self.context = persistentContainer.viewContext
    }

    // Save changes to context
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save mock context: \(error)")
        }
    }

    // Fetch items from context
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error in mock: \(error)")
            throw error
        }
    }

    // Add mock items to context
    func addMockCache(_ items: [CachedFeedItem]) {
        for item in items {
            context.insert(item)
        }
        saveContext()
    }

    // Manually reset cache (simulate batch delete)
    func resetMockCache() {
        let fetchRequest: NSFetchRequest<CachedFeedItem> = CachedFeedItem.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            saveContext()
        } catch {
            print("Failed to reset cache:", error)
        }
    }
}


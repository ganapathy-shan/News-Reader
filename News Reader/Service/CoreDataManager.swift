//
//  CoreDataManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


import CoreData

enum CoreDataError: Error {
    case saveFailed(Error)
}
class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()
    
    private init() {
        self.persistentContainer = {
            let container = NSPersistentContainer(name: "News_Reader")
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("Unresolved error \(error)")
                }
            }
            return container
        }()
    }

    // Allow dependency injection for tests
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Throw a custom error with the original error information
                throw CoreDataError.saveFailed(error)
            }
        }
    }

    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T] {
        return try context.fetch(request)
    }
}


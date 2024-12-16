//
//  MockPersistentContainer.swift
//  News Reader
//
//  Created by Shanmuganathan on 22/11/24.
//

import CoreData

class MockFailingContext: NSManagedObjectContext {
    override func save() throws {
        // Force a failure whenever save is called
        throw NSError(domain: "CoreData", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Failed to save context"])
    }
}

class MockPersistentContainer: NSPersistentContainer {
    var mockFailingContext: MockFailingContext

    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        self.mockFailingContext = MockFailingContext(concurrencyType: .mainQueueConcurrencyType)
        super.init(name: name, managedObjectModel: model)
        self.mockFailingContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
    
    override var viewContext: NSManagedObjectContext {
        return mockFailingContext  // Use the mock failing context for the viewContext
    }
}


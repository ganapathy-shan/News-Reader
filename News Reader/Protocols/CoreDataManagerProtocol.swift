//
//  CoreDataManagerProtocol.swift
//  News Reader
//
//  Created by Shanmuganathan on 21/11/24.
//


import CoreData

public protocol CoreDataManagerProtocol {
    var context: NSManagedObjectContext { get }
    func saveContext() throws
    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) throws -> [T]
}

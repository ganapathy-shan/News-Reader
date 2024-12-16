//
//  CacheManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 21/11/24.
//


import Foundation
import CoreData

class CacheManager {
    static let shared = CacheManager()
    var useBatchDelete: Bool = true
    
    var coreDataManager : CoreDataManagerProtocol = CoreDataManager.shared
    
    // Save the current date as the last launch date
    func saveLastLaunchDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: currentDate)
        
        UserDefaults.standard.set(currentDateString, forKey: "lastLaunchDate")
    }
    
    // Check if the cache should be reset
    func shouldResetCache() -> Bool {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: currentDate)
        
        // Get the stored date from UserDefaults
        if let storedDate = UserDefaults.standard.string(forKey: "lastLaunchDate") {
            // Compare dates
            if storedDate != currentDateString {
                return true
            }
        }
        
        return false
    }
    
    // Reset the cache by deleting CachedFeedItem entries
    func resetCache() {
        if shouldResetCache() {
            let context = coreDataManager.context
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedFeedItem.fetchRequest()
            
            do {
                if useBatchDelete {
                    // Use batch delete in production
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)
                } else {
                        // Manual deletion for tests
                        let items = try context.fetch(fetchRequest) as? [NSManagedObject]
                        items?.forEach { context.delete($0) }
                }

                try coreDataManager.saveContext()
                // Save the current date as the last launch date
                saveLastLaunchDate()
                
                print("Cache has been reset.")
            } catch CoreDataError.saveFailed(let error) {
                // Handle the error appropriately
                print("Failed to save context: \(error.localizedDescription)")
            } catch {
                // Handle other possible errors
                print("An unexpected error occurred: \(error)")
            }
            
        }
    }
}

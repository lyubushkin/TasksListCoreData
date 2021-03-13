//
//  StorageManager.swift
//  TasksListCoreData
//
//  Created by Swift on 13.03.2021.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TasksListCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getTask() -> Task? {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return nil }

        return task
    }
    
    func fetchRequest() -> NSFetchRequest<Task> {
        Task.fetchRequest()
    }
}

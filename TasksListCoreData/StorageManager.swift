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
    func saveContext(_ taskName: String? = nil) -> Task? {
        let context = persistentContainer.viewContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return nil }
        
        task.name = taskName
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        return task
    }
    
    func getTask() -> Task? {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return nil }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return nil }

        return task
    }
    
    func deleteTask(_ task: Task) {
        let context = persistentContainer.viewContext
        context.delete(task)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchRequest() -> NSFetchRequest<Task> {
        Task.fetchRequest()
    }
}

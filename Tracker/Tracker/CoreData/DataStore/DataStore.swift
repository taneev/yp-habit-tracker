//
//  DataStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//
import CoreData

protocol DataStoreProtocol: AnyObject {
    func getContext() -> NSManagedObjectContext?
}

final class DataStore: DataStoreProtocol {
    private var context: NSManagedObjectContext?
    private var persistentContainer: NSPersistentContainer

    private enum Constants {
        static let persistentContainerName = "HabitTracker"
        static let recordForUUIDPredicate = "%K == %@"
    }

    init() {
        self.persistentContainer = NSPersistentContainer(name: Constants.persistentContainerName)
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error {
                assertionFailure("Ошибка инициализации хранилища данных: \(error)")
            }
        })
        self.context = persistentContainer.viewContext
    }

    func getContext() -> NSManagedObjectContext?  {
        return context
    }
}

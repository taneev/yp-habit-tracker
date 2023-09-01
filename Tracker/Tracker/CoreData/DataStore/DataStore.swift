//
//  DataStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//
import UIKit
import CoreData

protocol DataStoreProtocol: AnyObject {
    var dataStoreFetchedResultController: DataStoreFetchedControllerProtocol? {get}
    func addRecord(_ record: TrackerRecordStore, toTrackerAt indexPath: IndexPath)
    func deleteRecord(_ record: TrackerRecordStore, forTrackerAt indexPath: IndexPath)
    func saveTracker(_ trackerStore: TrackerStore)
    func getContext() -> NSManagedObjectContext?
    
}

final class DataStore: DataStoreProtocol {
    var dataStoreFetchedResultController: DataStoreFetchedControllerProtocol?
    private var context: NSManagedObjectContext?
    private var persistentContainer: NSPersistentContainer

    init() {
        self.persistentContainer = NSPersistentContainer(name: "HabitTracker")
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error {
                assertionFailure("Ошибка инициализации хранилища данных: \(error)")
            }
        })
        self.context = persistentContainer.viewContext

        if let context {
            let controller = DataStoreFetchController(context: context)
            controller.delegate = controller
            self.dataStoreFetchedResultController = controller
        }
    }

    func addRecord(_ record: TrackerRecordStore, toTrackerAt indexPath: IndexPath) {
        guard let context,
              let fetchedTrackerController = dataStoreFetchedResultController?.fetchedTrackerController
        else {return}

        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.completedAt = record.completedAt
        recordCoreData.tracker = fetchedTrackerController.object(at: indexPath)

        try? context.save()
    }

    func deleteRecord(_ record: TrackerRecordStore, forTrackerAt indexPath: IndexPath) {
        guard let context,
              let fetchedTrackerController = dataStoreFetchedResultController?.fetchedTrackerController
        else {return}

        let tracker = fetchedTrackerController.object(at: indexPath)
        if let completed = tracker.completed as? Set<TrackerRecordCoreData> {
            completed.forEach{
                if record.completedAt.isEqual(to: $0.completedAt) {
                    context.delete($0)
                }
            }
            try? context.save()
        }
    }

    func saveTracker(_ trackerStore: TrackerStore) {
        guard let context else {return}

        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerCategoryCoreData.categoryID),
                trackerStore.category.categoryID.uuidString
        )
        guard let categoryCoreData = try? context.fetch(request).first else {return}

        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = trackerStore.name
        trackerCoreData.isRegular = trackerStore.isRegular
        trackerCoreData.emoji = trackerStore.emoji
        trackerCoreData.color = trackerStore.color
        trackerCoreData.schedule = trackerStore.schedule
        trackerCoreData.category = categoryCoreData
        try? context.save()
    }

    func getContext() -> NSManagedObjectContext?  {
        return context
    }
}

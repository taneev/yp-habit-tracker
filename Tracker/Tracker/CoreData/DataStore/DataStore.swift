//
//  DataStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//
import CoreData
import UIKit

protocol DataStoreProtocol: AnyObject {
    var dataStoreFetchedResultController: DataStoreFetchedControllerProtocol? {get}
    func addRecord(_ record: TrackerRecordStore)
    func deleteRecord(_ record: TrackerRecordStore)
    func saveTracker(_ trackerStore: TrackerStore)
    func getContext() -> NSManagedObjectContext?
}

final class DataStore: DataStoreProtocol {
    var dataStoreFetchedResultController: DataStoreFetchedControllerProtocol?
    private var context: NSManagedObjectContext?
    private var persistentContainer: NSPersistentContainer

    private enum Constants {
        static let persistentContainerName = "HabitTracker"
        static let recordForTrackerPredicate = "%K == %@ and %K == %@"
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

        if let context {
            let controller = DataStoreFetchController(context: context)
            controller.delegate = controller
            self.dataStoreFetchedResultController = controller
        }
    }

    func addRecord(_ record: TrackerRecordStore) {
        guard let context else {return}

        let tracker = getTracker(for: record.trackerID)
        let recordCoreData = TrackerRecordCoreData(context: context)
        let completedAt = record.completedAt.truncated() ?? record.completedAt

        recordCoreData.completedAt = completedAt
        recordCoreData.tracker = tracker
        recordCoreData.trackerID = record.trackerID

        try? context.save()
    }

    func deleteRecord(_ record: TrackerRecordStore) {
        guard let context,
              let completedAt = record.completedAt.truncated(),
              let tracker = getTracker(for: record.trackerID)
        else {return}

        let recordsRequest = TrackerRecordCoreData.fetchRequest()
        recordsRequest.predicate = NSPredicate(
            format: Constants.recordForTrackerPredicate,
            #keyPath(TrackerRecordCoreData.completedAt),
            completedAt as NSDate,
            #keyPath(TrackerRecordCoreData.tracker),
            tracker
        )
        if let records = try? context.fetch(recordsRequest) {
            records.forEach{context.delete($0)}
            try? context.save()
        }
    }

    func saveTracker(_ trackerStore: TrackerStore) {
        guard let context else {return}

        let categoryID = trackerStore.category.categoryID
        guard let category = getCategory(for: categoryID)
        else {return}

        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = trackerStore.trackerID
        trackerCoreData.name = trackerStore.name
        trackerCoreData.isRegular = trackerStore.isRegular
        trackerCoreData.emoji = trackerStore.emoji
        trackerCoreData.color = trackerStore.color
        trackerCoreData.schedule = trackerStore.schedule
        trackerCoreData.category = category
        trackerCoreData.categoryID = categoryID
        try? context.save()
    }

    func getContext() -> NSManagedObjectContext?  {
        return context
    }

    private func getCategory(for id: UUID) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: Constants.recordForUUIDPredicate,
            #keyPath(TrackerCategoryCoreData.categoryID),
            id as NSUUID
        )

        return try? context?.fetch(request).first as? TrackerCategoryCoreData
    }

    private func getTracker(for id: UUID) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: Constants.recordForUUIDPredicate,
            #keyPath(TrackerCoreData.trackerID),
            id as NSUUID
        )

        return try? context?.fetch(request).first as? TrackerCoreData
    }

}

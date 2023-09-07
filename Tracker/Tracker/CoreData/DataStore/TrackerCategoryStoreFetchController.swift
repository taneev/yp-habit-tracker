//
//  DataStoreFetchController.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import CoreData

final class CategoryStoreFetchController: NSObject {
    private weak var dataProviderDelegate: (any CategoryDataProviderProtocol)?

    private var dataStore: DataStoreProtocol?
    private var fetchedController:  NSFetchedResultsController<TrackerCategoryCoreData>?

    private var insertedIndexes = [IndexPath]()
    private var deletedIndexes = [IndexPath]()

    init(dataStore: DataStoreProtocol, dataProviderDelegate: any CategoryDataProviderProtocol) {
        super.init()
        self.dataStore = dataStore
        self.dataProviderDelegate = dataProviderDelegate
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.name), ascending: true)
        ]
        if let context = dataStore.getContext() {
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            self.fetchedController = controller
            self.fetchedController?.delegate = self
        }
    }
}

extension CategoryStoreFetchController: DataStoreFetchedControllerProtocol {
    var numberOfObjects: Int? {
        fetchedController?.fetchedObjects?.count
    }

    var numberOfSections: Int? {
        fetchedController?.sections?.count
    }

    func numberOfRows(in section: Int) -> Int? {
        fetchedController?.sections?[section].numberOfObjects
    }

    func object(at indexPath: IndexPath) -> TrackerCategoryStore? {
        guard let trackerCoreData = fetchedController?.object(at: indexPath)
        else {return nil}

        return TrackerCategoryStore(categoryCoreData: trackerCoreData)
    }

    func fetchData() {
        try? fetchedController?.performFetch()
    }
}

extension CategoryStoreFetchController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataProviderDelegate?.didUpdate(
            UpdatedIndexes(
                insertedSections: IndexSet(),
                insertedIndexes: insertedIndexes,
                deletedSections: IndexSet(),
                deletedIndexes: deletedIndexes
            )
        )
        insertedIndexes = []
        deletedIndexes = []
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {

        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes.append(indexPath)
            }
        default:
            break
        }
    }
}

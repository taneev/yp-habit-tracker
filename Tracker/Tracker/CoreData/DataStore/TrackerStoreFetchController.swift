//
//  DataStoreFetchController.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import CoreData

protocol DataStoreFetchedControllerProtocol {
    var dataProviderDelegate: DataProviderProtocol? {get set}
    //var fetchedTrackerController: NSFetchedResultsController<TrackerCoreData>? {get set}
    var numberOfObjects: Int? {get}
    var numberOfSections: Int? {get}
    func numberOfRows(in section: Int) -> Int?
    func object(at: IndexPath) -> TrackerStore?
    func fetchData()
    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String)
}

final class TrackerStoreFetchController: NSObject {
    weak var dataProviderDelegate: DataProviderProtocol?

    private var dataStore: DataStoreProtocol?
    private var fetchedController:  NSFetchedResultsController<TrackerCoreData>?

    private var insertedSections: IndexSet?
    private var insertedIndexes = [IndexPath]()

    private var deletedSections: IndexSet?
    private var deletedIndexes = [IndexPath]()

    init(dataStore: DataStoreProtocol) {
        super.init()
        self.dataStore = dataStore
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        if let context = dataStore.getContext() {
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: #keyPath(TrackerCoreData.category),
                cacheName: nil
            )
            self.fetchedController = controller
            self.fetchedController?.delegate = self
        }
    }

    private func createPredicateWith(selectedDate: Date, searchString: String? = nil) -> NSPredicate? {
        guard let currentWeekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: selectedDate))
        else {return nil}
        let weekDayText = WeekDay.shortWeekdayText[currentWeekDay] ?? ""

        let searchText = searchString?.trimmingCharacters(in: .whitespaces) ?? ""

        if searchText.isEmpty {
            return NSPredicate(
                        format: "%K == %@ OR %K CONTAINS[c] %@",
                        #keyPath(TrackerCoreData.isRegular),
                        NSNumber(booleanLiteral: false),
                        #keyPath(TrackerCoreData.schedule),
                        weekDayText
                   )
        }
        else {
            return NSPredicate(
                        format: "(%K == %@ OR %K CONTAINS[c] %@) AND %K CONTAINS[c] %@",
                        #keyPath(TrackerCoreData.isRegular),
                        NSNumber(booleanLiteral: false),
                        #keyPath(TrackerCoreData.schedule),
                        weekDayText,
                        #keyPath(TrackerCoreData.name),
                        searchText
                   )
        }
    }

}

extension TrackerStoreFetchController: DataStoreFetchedControllerProtocol {
    var numberOfObjects: Int? {
        fetchedController?.fetchedObjects?.count
    }

    var numberOfSections: Int? {
        fetchedController?.sections?.count
    }

    func numberOfRows(in section: Int) -> Int? {
        fetchedController?.sections?[section].numberOfObjects
    }

    func object(at indexPath: IndexPath) -> TrackerStore? {
        guard let trackerCoreData = fetchedController?.object(at: indexPath)
        else {return nil}

        return TrackerStore(trackerCoreData: trackerCoreData)
    }

    func fetchData() {
        try? fetchedController?.performFetch()
    }

    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String) {
        fetchedController?.fetchRequest.predicate = createPredicateWith(
                selectedDate: currentDate,
                searchString: searchTextFilter
        )
        try? fetchedController?.performFetch()
    }
}

extension TrackerStoreFetchController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections = IndexSet()
        insertedIndexes = []
        deletedSections = IndexSet()
        deletedIndexes = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataProviderDelegate?.didUpdate(
            UpdatedIndexes(
                insertedSections: insertedSections ?? IndexSet(),
                insertedIndexes: insertedIndexes,
                deletedSections: deletedSections ?? IndexSet(),
                deletedIndexes: deletedIndexes
            )
        )
        insertedSections = nil
        insertedIndexes = []

        deletedSections = nil
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
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {

        switch type {
        case .delete:
            deletedSections?.insert(sectionIndex)
        case .insert:
            insertedSections?.insert(sectionIndex)
        default:
            break
        }
    }
}

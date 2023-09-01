//
//  DataStoreFetchController.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import UIKit
import CoreData

protocol DataStoreFetchedControllerProtocol {
    var delegate: NSFetchedResultsControllerDelegate? {get set}
    var dataProviderDelegate: DataProviderProtocol? {get set}
    var fetchedTrackerController: NSFetchedResultsController<TrackerCoreData>? {get set}
    var numberOfSections: Int? {get}
    func numberOfRows(in section: Int) -> Int?
    func object(at: IndexPath) -> TrackerStore?
    func fetchData()
    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String)
}

final class DataStoreFetchController: NSObject {
    var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedTrackerController?.delegate = delegate
        }
    }
    var fetchedTrackerController:  NSFetchedResultsController<TrackerCoreData>?
    weak var dataProviderDelegate: DataProviderProtocol?

    private var insertedIndexes: [IndexPath]?
    private var deletedIndexes: [IndexPath]?
    
    init(context: NSManagedObjectContext) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: #keyPath(TrackerCoreData.category),
                cacheName: nil
        )
        self.fetchedTrackerController = controller
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

extension DataStoreFetchController: DataStoreFetchedControllerProtocol {
    var numberOfSections: Int? {
        fetchedTrackerController?.sections?.count
    }

    func numberOfRows(in section: Int) -> Int? {
        fetchedTrackerController?.sections?[section].numberOfObjects
    }

    func object(at indexPath: IndexPath) -> TrackerStore? {
        guard let trackerCoreData = fetchedTrackerController?.object(at: indexPath)
        else {return nil}

        return TrackerStore(trackerCoreData: trackerCoreData)
    }

    func fetchData() {
        try? fetchedTrackerController?.performFetch()
    }

    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String) {
        fetchedTrackerController?.fetchRequest.predicate = createPredicateWith(
                selectedDate: currentDate,
                searchString: searchTextFilter
        )
        try? fetchedTrackerController?.performFetch()
    }
}

extension DataStoreFetchController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataProviderDelegate?.didUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.append(indexPath)
            }
        default:
            break
        }
    }
}

//
//  DataProvider.swift
//  Tracker
//
//  Created by Тимур Танеев on 29.08.2023.
//
import UIKit

protocol DataProviderProtocol: AnyObject {
    var numberOfObjects: Int {get}
    var numberOfSections: Int {get}
    var dataStore: DataStoreProtocol {get}
    func numberOfRows(in section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func loadData()
    func getDefaultCategory() -> TrackerCategory?
    func save(tracker: Tracker, in categoryID: TrackerCategory)
    func getCategoryNameForTracker(at indexPath: IndexPath) -> String
    func setDateFilter(with date: Date)
    func setSearchTextFilter(with searchText: String)
    func switchTracker(at indexPath: IndexPath, to isCompleted: Bool, for date: Date)
    func getCompletedRecordsForTracker(at indexPath: IndexPath) -> Int
    func didUpdate(_ updatedIndexes: UpdatedIndexes)
}

struct UpdatedIndexes {
    let insertedSections: IndexSet
    let insertedIndexes: [IndexPath]
    let deletedSections: IndexSet
    let deletedIndexes: [IndexPath]
}

final class DataProvider {
    private weak var delegate: DataProviderDelegate?
    var dataStore: DataStoreProtocol
    private var dataStoreFetchedController: DataStoreFetchedControllerProtocol?
    private var currentDate: Date = Date()
    private var searchText: String = ""

    init(delegate: DataProviderDelegate) {
        self.delegate = delegate
        self.dataStore = DataStore()
        self.dataStoreFetchedController = dataStore.dataStoreFetchedResultController
        self.dataStoreFetchedController?.dataProviderDelegate = self
    }

    private func completeTracker(at indexPath: IndexPath, for date: Date) {
        let recordStore = TrackerRecordStore(completedAt: date)
        dataStore.addRecord(recordStore, toTrackerAt: indexPath)
    }

    private func uncompleteTracker(at indexPath: IndexPath, for date: Date) {
        let recordStore = TrackerRecordStore(completedAt: date)
        dataStore.deleteRecord(recordStore, forTrackerAt: indexPath)
    }
}

extension DataProvider: DataProviderProtocol {
    func didUpdate(_ updatedIndexes: UpdatedIndexes) {
        delegate?.didUpdateIndexPath(updatedIndexes)
    }

    func switchTracker(at indexPath: IndexPath, to isCompleted: Bool, for date: Date) {
        if isCompleted {
            completeTracker(at: indexPath, for: date)
        }
        else {
            uncompleteTracker(at: indexPath, for: date)
        }
    }

    func getCompletedRecordsForTracker(at indexPath: IndexPath) -> Int {
        guard let tracker = dataStoreFetchedController?.object(at: indexPath) else {return 0}
        return tracker.completed?.count ?? 0
    }

    func setDateFilter(with date: Date) {
        self.currentDate = date
        dataStoreFetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    func setSearchTextFilter(with searchText: String) {
        self.searchText = searchText
        dataStoreFetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    var numberOfObjects: Int {
        dataStoreFetchedController?.numberOfObjects ?? 0
    }

    var numberOfSections: Int {
        dataStoreFetchedController?.numberOfSections ?? 1
    }

    func numberOfRows(in section: Int) -> Int {
        dataStoreFetchedController?.numberOfRows(in: section) ?? 0
    }

    func object(at indexPath: IndexPath) -> Tracker? {
        guard let trackerStore = dataStoreFetchedController?.object(at: indexPath)
        else {return nil}

        let color = UIColor.YpColors(rawValue: trackerStore.color)
        let schedule = WeekDay.getWeekDays(from: trackerStore.schedule ?? "")
        let completedDates = trackerStore.completed
        let isCompleted = completedDates?.first(where: { currentDate.isEqual(to: $0.completedAt)}) != nil
        let tracker = Tracker(
                        name: trackerStore.name,
                        isRegular: trackerStore.isRegular,
                        emoji: trackerStore.emoji,
                        color: color,
                        schedule: schedule,
                        isCompleted: isCompleted,
                        completedCounter: completedDates?.count ?? 0
        )
        return tracker
    }

    func loadData() {
        dataStoreFetchedController?.fetchData()
    }

    func getDefaultCategory() -> TrackerCategory? {
        guard let categoryStore = MockDataGenerator.getDefaultCategory(for: dataStore)
        else {return nil}

        return TrackerCategory(id: categoryStore.categoryID, name: categoryStore.name)
    }

    func save(tracker: Tracker, in category: TrackerCategory) {

        let trackerStore = TrackerStore(
            name: tracker.name,
            isRegular: tracker.isRegular,
            emoji: tracker.emoji,
            color: tracker.color?.rawValue ?? "",
            schedule: WeekDay.getDescription(for: tracker.schedule ?? []),
            category: TrackerCategoryStore(categoryID: category.categoryID, name: category.name),
            completed: nil
        )

        dataStore.saveTracker(trackerStore)
    }

    func getCategoryNameForTracker(at indexPath: IndexPath) -> String {
        guard let tracker = dataStoreFetchedController?.object(at: indexPath) else {return ""}
        return tracker.category.name
    }
}

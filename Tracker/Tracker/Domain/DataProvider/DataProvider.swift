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
    func switchTracker(withID trackerID: UUID, to isCompleted: Bool, for date: Date)
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
    private var trackerStoreFetchedController: DataStoreFetchedControllerProtocol?
    private var currentDate: Date = Date()
    private var searchText: String = ""

    init(delegate: DataProviderDelegate) {
        self.delegate = delegate
        self.dataStore = DataStore()
        self.trackerStoreFetchedController = TrackerStoreFetchController(dataStore: dataStore)
        self.trackerStoreFetchedController?.dataProviderDelegate = self
    }

    private func completeTracker(withID trackerID: UUID, for date: Date) {
        guard let context = dataStore.getContext() else {return}

        let recordStore = TrackerRecordStore(trackerID: trackerID, completedAt: date)
        recordStore.addRecord(context: context)
    }

    private func uncompleteTracker(withID trackerID: UUID, for date: Date) {
        guard let context = dataStore.getContext() else {return}

        let recordStore = TrackerRecordStore(trackerID: trackerID, completedAt: date)
        recordStore.deleteRecord(context: context)
    }
}

extension DataProvider: DataProviderProtocol {
    func didUpdate(_ updatedIndexes: UpdatedIndexes) {
        delegate?.didUpdateIndexPath(updatedIndexes)
    }

    func switchTracker(withID trackerID: UUID, to isCompleted: Bool, for date: Date) {
        if isCompleted {
            completeTracker(withID: trackerID, for: date)
        }
        else {
            uncompleteTracker(withID: trackerID, for: date)
        }
    }

    func getCompletedRecordsForTracker(at indexPath: IndexPath) -> Int {
        guard let tracker = trackerStoreFetchedController?.object(at: indexPath) else {return 0}
        return tracker.completed?.count ?? 0
    }

    func setDateFilter(with date: Date) {
        self.currentDate = date
        trackerStoreFetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    func setSearchTextFilter(with searchText: String) {
        self.searchText = searchText
        trackerStoreFetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    var numberOfObjects: Int {
        trackerStoreFetchedController?.numberOfObjects ?? 0
    }

    var numberOfSections: Int {
        trackerStoreFetchedController?.numberOfSections ?? 1
    }

    func numberOfRows(in section: Int) -> Int {
        trackerStoreFetchedController?.numberOfRows(in: section) ?? 0
    }

    func object(at indexPath: IndexPath) -> Tracker? {
        guard let trackerStore = trackerStoreFetchedController?.object(at: indexPath)
        else {return nil}

        let color = UIColor.YpColors(rawValue: trackerStore.color)
        let schedule = WeekDay.getWeekDays(from: trackerStore.schedule ?? "")
        let completedDates = trackerStore.completed
        let isCompleted = completedDates?.first(where: { currentDate.isEqual(to: $0.completedAt)}) != nil
        let tracker = Tracker(
                        trackerID: trackerStore.trackerID,
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
        trackerStoreFetchedController?.fetchData()
    }

    func getDefaultCategory() -> TrackerCategory? {
        guard let categoryStore = MockDataGenerator.getDefaultCategory(for: dataStore)
        else {return nil}

        return TrackerCategory(id: categoryStore.categoryID, name: categoryStore.name)
    }

    func save(tracker: Tracker, in category: TrackerCategory) {

        guard let context = dataStore.getContext() else {return}

        let trackerStore = TrackerStore(
            trackerID: tracker.trackerID,
            name: tracker.name,
            isRegular: tracker.isRegular,
            emoji: tracker.emoji,
            color: tracker.color?.rawValue ?? "",
            schedule: WeekDay.getDescription(for: tracker.schedule ?? []),
            category: TrackerCategoryStore(categoryID: category.categoryID, name: category.name),
            completed: nil
        )

        trackerStore.addRecord(context: context)
    }

    func getCategoryNameForTracker(at indexPath: IndexPath) -> String {
        guard let tracker = trackerStoreFetchedController?.object(at: indexPath) else {return ""}
        return tracker.category.name
    }
}

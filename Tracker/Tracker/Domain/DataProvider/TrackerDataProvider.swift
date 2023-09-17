//
//  DataProvider.swift
//  Tracker
//
//  Created by Тимур Танеев on 29.08.2023.
//
import UIKit

protocol TrackerDataProviderProtocol: AnyObject, DataProviderForDataSource, DataProviderForCollectionLayoutDelegate {
    var dataStore: DataStoreProtocol { get }
    var numberOfObjects: Int { get }
    func indexPath(for trackerID: UUID) -> IndexPath?
    func loadData()
    func save(tracker: Tracker, in categoryID: TrackerCategory)
    func getCategoryForTracker(at indexPath: IndexPath) -> TrackerCategory?
    func setDateFilter(with date: Date)
    func setSearchTextFilter(with searchText: String)
    func switchTracker(withID trackerID: UUID, to isCompleted: Bool, for date: Date)
    func getCompletedRecordsForTracker(at indexPath: IndexPath) -> Int
    func pinTracker(to isPinned: Bool, at indexPath: IndexPath)
    func deleteTracker(at indexPath: IndexPath)
}

final class TrackerDataProvider {
    private weak var delegate: TrackerDataProviderDelegate?
    var dataStore: DataStoreProtocol
    private var fetchedController: (any TrackerStoreFetchControllerProtocol)?
    private var currentDate: Date = Date()
    private var searchText: String = ""

    init(delegate: TrackerDataProviderDelegate) {
        self.delegate = delegate
        self.dataStore = DataStore.shared
        self.fetchedController = TrackerFetchedController(
                dataStore: dataStore,
                dataProviderDelegate: self
        )
    }

    private func completeTracker(withID trackerID: UUID, for date: Date) {
        guard let context = dataStore.getContext() else { return }

        let recordStore = TrackerRecordStore(trackerID: trackerID, completedAt: date)
        recordStore.addRecord(context: context)
    }

    private func uncompleteTracker(withID trackerID: UUID, for date: Date) {
        guard let context = dataStore.getContext() else { return }

        let recordStore = TrackerRecordStore(trackerID: trackerID, completedAt: date)
        recordStore.deleteRecord(context: context)
    }
}

extension TrackerDataProvider: DataProviderForDataSource {
    typealias T = Tracker

    var numberOfSections: Int {
        fetchedController?.numberOfSections ?? 1
    }

    func numberOfRows(in section: Int) -> Int {
        fetchedController?.numberOfRows(in: section) ?? 0
    }

    func object(at indexPath: IndexPath) -> T? {
        guard let trackerStore = fetchedController?.object(at: indexPath) as? TrackerStore
        else { return nil }

        let color = UIColor.YpColors(rawValue: trackerStore.color)
        let schedule = WeekDay.getWeekDays(from: trackerStore.schedule ?? "")
        let completedDates = trackerStore.completed
        let isCompleted = completedDates?.first(where: { currentDate.isEqual(to: $0.completedAt)}) != nil
        let tracker = T(
                        trackerID: trackerStore.trackerID,
                        name: trackerStore.name,
                        isRegular: trackerStore.isRegular,
                        emoji: trackerStore.emoji,
                        color: color,
                        schedule: schedule,
                        isCompleted: isCompleted,
                        completedCounter: completedDates?.count ?? 0,
                        isPinned: trackerStore.isPinned
        )
        return tracker
    }
}

extension TrackerDataProvider: DataProviderForCollectionLayoutDelegate {
    func didUpdate(_ updatedIndexes: UpdatedIndexes) {
        delegate?.didUpdateIndexPath(updatedIndexes)
    }
}

extension TrackerDataProvider: TrackerDataProviderProtocol {
    func indexPath(for trackerID: UUID) -> IndexPath? {
        fetchedController?.indexPath(for: trackerID)
    }

    var numberOfObjects: Int {
        fetchedController?.numberOfObjects ?? 0
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
        guard let tracker = fetchedController?.object(at: indexPath) as? TrackerStore
        else { return .zero }
        return tracker.completed?.count ?? 0
    }

    func setDateFilter(with date: Date) {
        self.currentDate = date
        fetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    func setSearchTextFilter(with searchText: String) {
        self.searchText = searchText
        fetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    func loadData() {
        fetchedController?.fetchData()
    }

    func save(tracker: Tracker, in category: TrackerCategory) {
        guard let context = dataStore.getContext() else { return }

        if let trackerStoreForUpdate = TrackerStore.getRecord(for: tracker.trackerID, context: context) {
            let updatedTrackerStore = TrackerStore(
                trackerID: trackerStoreForUpdate.trackerID,
                name: tracker.name,
                isRegular: trackerStoreForUpdate.isRegular,
                emoji: tracker.emoji,
                color: tracker.color?.rawValue ?? "",
                schedule: WeekDay.getDescription(for: tracker.schedule ?? []),
                category: TrackerCategoryStore(categoryID: category.categoryID, name: category.name),
                completed: trackerStoreForUpdate.completed,
                isPinned: trackerStoreForUpdate.isPinned
            )
            updatedTrackerStore.updateRecord(context: context)
        }
        else {
            let trackerStore = TrackerStore(
                trackerID: tracker.trackerID,
                name: tracker.name,
                isRegular: tracker.isRegular,
                emoji: tracker.emoji,
                color: tracker.color?.rawValue ?? "",
                schedule: WeekDay.getDescription(for: tracker.schedule ?? []),
                category: TrackerCategoryStore(categoryID: category.categoryID, name: category.name),
                completed: nil,
                isPinned: tracker.isPinned
            )
            trackerStore.addRecord(context: context)
        }
    }

    func getCategoryForTracker(at indexPath: IndexPath) -> TrackerCategory? {
        guard let tracker = fetchedController?.object(at: indexPath) as? TrackerStore
        else { return nil }
        return TrackerCategory(id: tracker.category.categoryID, name: tracker.category.name)
    }

    func pinTracker(to isPinned: Bool, at indexPath: IndexPath) {
        guard let context = dataStore.getContext() else { return }
        guard let trackerStore = fetchedController?.object(at: indexPath) as? TrackerStore
        else { return }
        let trackerUpdated = TrackerStore(
            trackerID: trackerStore.trackerID,
            name: trackerStore.name,
            isRegular: trackerStore.isRegular,
            emoji: trackerStore.emoji,
            color: trackerStore.color,
            schedule: trackerStore.schedule,
            category: trackerStore.category,
            completed: trackerStore.completed,
            isPinned: isPinned)
        trackerUpdated.updateRecord(context: context)
    }

    func deleteTracker(at indexPath: IndexPath) {
        guard let tracker = object(at: indexPath),
              let context = dataStore.getContext()
        else { return }

        TrackerStore.deleteRecord(with: tracker.trackerID, context: context)
    }
}

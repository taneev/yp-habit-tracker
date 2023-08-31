//
//  DataProvider.swift
//  Tracker
//
//  Created by Тимур Танеев on 29.08.2023.
//
import UIKit

protocol DataProviderProtocol {
    var numberOfSections: Int {get}
    func numberOfRows(in section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func loadData()
    func getDefaultCategory() -> TrackerCategory?
    func save(tracker: Tracker, in categoryID: TrackerCategory)
    func getCategoryNameForTracker(at indexPath: IndexPath) -> String
    func setDateFilter(with date: Date)
    func setSearchTextFilter(with searchText: String)
    func switchTracker(at indexPath: IndexPath, to isCompleted: Bool, for date: Date)
}

final class DataProvider {
    private var dataStore: DataStoreProtocol
    private var dataStoreFetchedController: DataStoreFetchedControllerProtocol?
    private var currentDate: Date = Date()
    private var searchText: String = ""

    init() {
        self.dataStore = DataStore()
        self.dataStoreFetchedController = dataStore.dataStoreFetchedResultController
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
    func switchTracker(at indexPath: IndexPath, to isCompleted: Bool, for date: Date) {
        if isCompleted {
            completeTracker(at: indexPath, for: date)
        }
        else {
            uncompleteTracker(at: indexPath, for: date)
        }
    }

    func setDateFilter(with date: Date) {
        self.currentDate = date
        dataStoreFetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    func setSearchTextFilter(with searchText: String) {
        self.searchText = searchText
        dataStoreFetchedController?.updateFilterWith(selectedDate: currentDate, searchString: searchText)
    }

    var numberOfSections: Int {
        dataStoreFetchedController?.numberOfSections ?? 0
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
        let completedByDate = completedDates?.filter{
                currentDate.isGreater(than: $0.completedAt) || currentDate.isEqual(to: $0.completedAt)
            }
        let tracker = Tracker(
                        name: trackerStore.name,
                        isRegular: trackerStore.isRegular,
                        emoji: trackerStore.emoji,
                        color: color,
                        schedule: schedule,
                        isCompleted: isCompleted,
                        completedCounter: completedByDate == nil ? 0 : completedByDate!.count
        )
        return tracker
    }

    func loadData() {
        // Загрузим мок-данные в БД для тестирования пока нет функциональности добавления категорий
        MockDataGenerator.setupRecords(in: dataStore)
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
        dataStoreFetchedController?.fetchData()
    }

    func getCategoryNameForTracker(at indexPath: IndexPath) -> String {
        guard let tracker = dataStoreFetchedController?.object(at: indexPath) else {return ""}
        return tracker.category.name
    }
}

//
//  DataProvider.swift
//  Tracker
//
//  Created by Тимур Танеев on 29.08.2023.
//
import UIKit
import CoreData

protocol DataProviderProtocol {
    var numberOfSections: Int {get}
    func numberOfRows(in section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func loadData()
    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String)
    func hasCompletedRecords(at indexPath: IndexPath, for date: Date) -> Bool
    func completeTracker(at indexPath: IndexPath, for date: Date)
    func uncompleteTracker(at indexPath: IndexPath, for date: Date)
    func getCompletedTrackersCount(at indexPath: IndexPath, for date: Date) -> Int
    func getDefaultCategory() -> TrackerCategory?
    func save(tracker: Tracker, in categoryID: UUID)
    func getCategoryNameForObject(at indexPath: IndexPath) -> String
}

final class DataProvider: NSObject {
    private lazy var mainContext = { getMainContext() }()
    private lazy var fetchResultController = { initFetchResultController() }()

    private func getMainContext() -> NSManagedObjectContext?  {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer?.viewContext
    }

    private func initFetchResultController() -> NSFetchedResultsController<TrackerCoreData>? {
        guard let mainContext else {return nil}

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        if let predicate = createPredicateWith(selectedDate: Date(), searchString: "") {
            fetchRequest.predicate = predicate
        }
        let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: mainContext,
                sectionNameKeyPath: #keyPath(TrackerCoreData.category),
                cacheName: nil
        )
        controller.delegate = self
        return controller
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {
    
}

extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchResultController?.sections?.count ?? 0
    }

    func numberOfRows(in section: Int) -> Int {
        fetchResultController?.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> Tracker? {
        guard let trackerCoreData = fetchResultController?.object(at: indexPath),
              let name = trackerCoreData.name,
              let emoji = trackerCoreData.emoji,
              let color = UIColor.YpColors(rawValue: trackerCoreData.color ?? "")
        else {return nil}

        let schedule = WeekDay.getWeekDays(from: trackerCoreData.schedule ?? "")
        let tracker = Tracker(
                        name: name,
                        isRegular: trackerCoreData.isRegular,
                        emoji: emoji,
                        color: color,
                        schedule: schedule
        )
        return tracker
    }

    func loadData() {
        // Для тестирования пока нет функциональности добавления категорий загрузим мок-данные в БД
        MockDataGenerator.setupRecords(with: mainContext)
        try? fetchResultController?.performFetch()
    }

    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String) {
        fetchResultController?.fetchRequest.predicate = createPredicateWith(
                selectedDate: currentDate,
                searchString: searchTextFilter
        )
        try? fetchResultController?.performFetch()
    }

    func hasCompletedRecords(at indexPath: IndexPath, for date: Date) -> Bool {
        guard let tracker = fetchResultController?.object(at: indexPath),
              let completedDates = tracker.completed as? Set<TrackerRecordCoreData>
        else {return false}

        return completedDates.first(where: { date.isEqual(to: $0.completedAt)}) != nil
    }

    func completeTracker(at indexPath: IndexPath, for date: Date) {
        guard let mainContext,
              let tracker = fetchResultController?.object(at: indexPath) else {return}

        let record = TrackerRecordCoreData(context: mainContext)
        record.completedAt = date
        record.tracker = tracker
        try? mainContext.save()
    }

    func uncompleteTracker(at indexPath: IndexPath, for date: Date) {
        guard let mainContext,
              let tracker = fetchResultController?.object(at: indexPath),
              let completed = tracker.completed as? Set<TrackerRecordCoreData>
        else {return}

        completed.forEach{ record in
            if date.isEqual(to: record.completedAt) {
                mainContext.delete(record)
            }
        }
        try? mainContext.save()
    }

    func getCompletedTrackersCount(at indexPath: IndexPath, for date: Date) -> Int {
        guard let tracker = fetchResultController?.object(at: indexPath),
              let completedDates = tracker.completed as? Set<TrackerRecordCoreData>
        else {return 0}

        let records: Set<TrackerRecordCoreData> = completedDates.filter{
            date.isGreater(than: $0.completedAt) || date.isEqual(to: $0.completedAt)
        }
        return records.count
    }

    func getDefaultCategory() -> TrackerCategory? {
        guard let categoryCoreData = MockDataGenerator.getDefaultCategory(with: mainContext),
              let categoryID = categoryCoreData.categoryID else {return nil}

        var trackers: [Tracker]? = nil
        if let activeTrackers = categoryCoreData.activeTrackers as? Set<TrackerCoreData> {
            trackers = activeTrackers.compactMap{ tracker in
                    guard let name = tracker.name,
                          let emoji = tracker.emoji,
                          let color = UIColor.YpColors(rawValue: tracker.color ?? "")
                    else {return nil}

                    let schedule = WeekDay.getWeekDays(from: tracker.schedule ?? "")
                    let tracker = Tracker(
                                    name: name,
                                    isRegular: tracker.isRegular,
                                    emoji: emoji,
                                    color: color,
                                    schedule: schedule
                    )
                    return tracker
            }
        }
        let category = TrackerCategory(
                            id: categoryID,
                            name: categoryCoreData.name ?? "",
                            activeTrackers: trackers
        )
        return category
    }

    func save(tracker: Tracker, in categoryID: UUID) {
        guard let mainContext else {return}

        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerCategoryCoreData.categoryID),
                categoryID.uuidString
        )
        guard let categoryCoreData = try? mainContext.fetch(request).first else {return}

        let trackerCoreData = TrackerCoreData(context: mainContext)
        trackerCoreData.name = tracker.name
        trackerCoreData.isRegular = tracker.isRegular
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.rawValue
        trackerCoreData.schedule = WeekDay.getDescription(for: tracker.schedule ?? [])
        trackerCoreData.category = categoryCoreData
        try? mainContext.save()
        try? fetchResultController?.performFetch()
    }

    func getCategoryNameForObject(at indexPath: IndexPath) -> String {
        guard let tracker = fetchResultController?.object(at: indexPath) else {return ""}
        return tracker.category?.name ?? ""
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

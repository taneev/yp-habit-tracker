//
//  QueryBuilder.swift
//  Tracker
//
//  Created by Тимур Танеев on 20.09.2023.
//

import Foundation

final class PredicateQuery {
    var queryFormat: String
    var args: [CVarArg]

    init(queryFormat: String, args: [CVarArg]) {
        self.queryFormat = queryFormat
        self.args = args
    }

    private func append(queryFormat: String, args: [CVarArg]) {
        if self.queryFormat.trimmingCharacters(in: .whitespaces).isEmpty {
            self.queryFormat = queryFormat
        }
        else {
            self.queryFormat += " AND " + queryFormat
        }
        self.args.append(contentsOf: args)
    }

    func append(query: PredicateQuery?) {
        guard let query else { return }
        append(queryFormat: query.queryFormat, args: query.args)
    }
}

private enum TrackerListPredicates {
    static let isPinnedQuery = " %K == %@ "
    static let dateQuery = " (%K == %@ OR %K CONTAINS[c] %@) "
    static let textQuery = " %K CONTAINS[c] %@ "
    static let completedQuery = " SUBQUERY(%K, $x, $x.completedAt == %@).@count > 0 "
    static let incompletedQuery = " SUBQUERY(%K, $x, $x.completedAt == %@).@count = 0 "
}

final class TrackerQueryBuilder {

    private let isPinned: Bool
    private let selectedDate: Date
    private var searchString: String?
    private var isCompleted: Bool?

    init(isPinned: Bool, selectedDate: Date, searchString: String? = nil, isCompleted: Bool? = nil) {
        self.isPinned = isPinned
        self.selectedDate = selectedDate
        self.searchString = searchString
        self.isCompleted = isCompleted
    }

    func createQuery() -> PredicateQuery {
        let query = Self.queryForIsPinned(isPinned)
        query.append(query: Self.queryForDate(selectedDate))

        if let searchString {
            let searchText = searchString.trimmingCharacters(in: .whitespaces)
            if !searchText.isEmpty {
                query.append(query: Self.queryForSearchText(searchText))
            }
        }

        if let filterDate = selectedDate.truncated() {
            query.append(query: Self.queryForCompleted(selectedDate: filterDate, isCompleted))
        }
        return query
    }

    static func queryForIsPinned(_ isPinned: Bool) -> PredicateQuery {
        let query = PredicateQuery(queryFormat: TrackerListPredicates.isPinnedQuery, args: [
            #keyPath(TrackerCoreData.isPinned),
            NSNumber(booleanLiteral: isPinned)
        ])
        return query
    }

    static func queryForDate(_ date: Date) -> PredicateQuery? {
        if let currentWeekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: date)) {
            let weekDayText = WeekDay.shortWeekdayText[currentWeekDay] ?? ""
            let query = PredicateQuery(
                queryFormat: TrackerListPredicates.dateQuery,
                args: [
                    #keyPath(TrackerCoreData.isRegular),
                    NSNumber(booleanLiteral: false),
                    #keyPath(TrackerCoreData.schedule),
                    weekDayText,
                ])
            return query
        }
        else {
            return nil
        }
    }

    static func queryForSearchText(_ text: String) -> PredicateQuery {
        let query = PredicateQuery(
            queryFormat: TrackerListPredicates.textQuery,
            args: [
                #keyPath(TrackerCoreData.name),
                text,
            ])
        return query
    }

    static func queryForCompleted(selectedDate: Date, _ isCompleted: Bool? = nil) -> PredicateQuery? {
        guard let isCompleted else { return nil }

        let format = isCompleted ? TrackerListPredicates.completedQuery : TrackerListPredicates.incompletedQuery
        let query = PredicateQuery(
            queryFormat: format,
            args: [
                #keyPath(TrackerCoreData.completed),
                selectedDate as NSDate
            ])
        return query
    }
}

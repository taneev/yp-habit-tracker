//
//  Extensions+Date.swift
//  Tracker
//
//  Created by Тимур Танеев on 28.08.2023.
//

import Foundation

extension Date {
    func isEqual(to date: Date?, toGranularity component: Calendar.Component = .day) -> Bool {
        guard let date else {return false}
        return Calendar.current.compare(self, to: date, toGranularity: component) == .orderedSame
    }

    func isGreater(than date: Date?, toGranularity component: Calendar.Component = .day) -> Bool {
        guard let date else {return false}
        return Calendar.current.compare(self, to: date, toGranularity: component) == .orderedDescending
    }

    func truncated() -> Date? {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let utcTimeZone = TimeZone(abbreviation: "UTC") else {return nil}
        dateComponents.timeZone = utcTimeZone
        return Calendar.current.date(from: dateComponents)
    }
}

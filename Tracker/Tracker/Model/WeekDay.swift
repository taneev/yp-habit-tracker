//
//  WeekDay.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case sun = 1, // для соответствия григорианскому календарю в Calendar,
                  // другие календари не поддерживаются
         mon, tue, wed, thu, fri, sat

    static let shortWeekdayText: [WeekDay: String] = [
        .sun: "Вс",
        .mon: "Пн",
        .tue: "Вт",
        .wed: "Ср",
        .thu: "Чт",
        .fri: "Пт",
        .sat: "Сб",
    ]

    static func getDescription(for schedule: [WeekDay]) -> String {
        let description = schedule.compactMap{ WeekDay.shortWeekdayText[$0] }.joined(separator: ", ")
        return description
    }
}

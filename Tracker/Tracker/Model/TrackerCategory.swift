//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import Foundation

/// Структура для хранения категорий трекеров
struct TrackerCategory {
    /// ID категории
    let categoryID: UUID

    /// имя категории
    let name: String

    /// коллекция активных трекеров, привязанных к категории
    let activeTrackers: [Tracker]?

    init(
        categoryID: UUID,
        name: String,
        activeTrackers: [Tracker]?
    ) {
        self.categoryID = categoryID
        self.name = name
        self.activeTrackers = activeTrackers
    }
}

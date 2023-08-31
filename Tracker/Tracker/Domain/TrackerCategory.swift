//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import Foundation

/// Структура для хранения категорий трекеров
struct TrackerCategory {
    /// Уникальный UUID категории
    let categoryID: UUID

    /// имя категории
    let name: String

    init(
        id: UUID,
        name: String
    ) {
        self.categoryID = id
        self.name = name
    }
}

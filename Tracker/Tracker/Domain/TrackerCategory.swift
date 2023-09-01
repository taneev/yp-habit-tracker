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
    let categoryID: URL

    /// имя категории
    let name: String

    init(
        id: URL,
        name: String
    ) {
        self.categoryID = id
        self.name = name
    }
}

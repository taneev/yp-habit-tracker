//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import Foundation

struct TrackerCategoryStore {
    let categoryID: UUID
    let name: String

    init(categoryID: UUID?, name: String) {
        self.categoryID = categoryID ?? UUID()
        self.name = name
    }

    init(categoryCoreData: TrackerCategoryCoreData) {
        self.init(categoryID: categoryCoreData.categoryID, name: categoryCoreData.name ?? "")
    }
}

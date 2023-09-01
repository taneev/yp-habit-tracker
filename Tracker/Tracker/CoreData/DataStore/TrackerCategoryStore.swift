//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import Foundation

struct TrackerCategoryStore {
    let categoryID: URL
    let name: String

    init(categoryID: URL, name: String) {
        self.categoryID = categoryID
        self.name = name
    }

    init(categoryCoreData: TrackerCategoryCoreData) {
        self.init(
            categoryID: categoryCoreData.objectID.uriRepresentation(),
            name: categoryCoreData.name ?? ""
        )
    }
}

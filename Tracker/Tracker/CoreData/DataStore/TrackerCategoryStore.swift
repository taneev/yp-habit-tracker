//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import CoreData

struct TrackerCategoryStore {
    let categoryID: UUID
    let name: String

    init(categoryID: UUID, name: String) {
        self.categoryID = categoryID
        self.name = name
    }

    init(categoryCoreData: TrackerCategoryCoreData) {
        self.init(
            categoryID: categoryCoreData.categoryID ?? UUID(),
            name: categoryCoreData.name ?? ""
        )
    }

    func addRecord(context: NSManagedObjectContext) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.categoryID = categoryID
        categoryCoreData.name = name
        try? context.save()
    }
}

//
//  TrackerStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import CoreData

struct TrackerStore {
    let trackerID: UUID
    let name: String
    let isRegular: Bool
    let emoji: String
    let color: String
    let schedule: String?
    let category: TrackerCategoryStore
    let completed: [TrackerRecordStore]?

    init(
        trackerID: UUID,
        name: String,
        isRegular: Bool,
        emoji: String,
        color: String,
        schedule: String?,
        category: TrackerCategoryStore,
        completed: [TrackerRecordStore]?
    ) {
        self.trackerID = trackerID
        self.name = name
        self.isRegular = isRegular
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.category = category
        self.completed = completed
    }

    init(trackerCoreData: TrackerCoreData) {
        let trackerID = trackerCoreData.trackerID ?? UUID()
        let completedRecords = trackerCoreData.completed as? Set<TrackerRecordCoreData>
        let completedStoreRecords = completedRecords?.compactMap{ record -> TrackerRecordStore? in
            guard let completedAt = record.completedAt?.truncated() else {return nil}
            return TrackerRecordStore(trackerID: trackerID, completedAt: completedAt)
        }

        self.init(
            trackerID: trackerID,
            name: trackerCoreData.name ?? "",
            isRegular: trackerCoreData.isRegular,
            emoji: trackerCoreData.emoji ?? "",
            color: trackerCoreData.color ?? "",
            schedule: trackerCoreData.schedule,
            category: TrackerCategoryStore(
                categoryID: trackerCoreData.categoryID ?? UUID(),
                name: trackerCoreData.category?.name ?? ""
            ),
            completed: completedStoreRecords
        )
    }
}

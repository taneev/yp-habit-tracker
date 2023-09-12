//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Тимур Танеев on 30.08.2023.
//

import CoreData

struct TrackerRecordStore {
    let trackerID: UUID
    let completedAt: Date

    init(trackerID: UUID, completedAt: Date) {
        self.trackerID = trackerID
        self.completedAt = completedAt
    }

    private enum Constants {
        static let recordForTrackerPredicate = "%K == %@ and %K == %@"
    }

    func addRecord(context: NSManagedObjectContext) {
        let tracker = TrackerCoreData.fetchRecord(for: trackerID, context: context)
        let recordCoreData = TrackerRecordCoreData(context: context)
        let completedAt = completedAt.truncated() ?? completedAt

        recordCoreData.completedAt = completedAt
        recordCoreData.tracker = tracker
        recordCoreData.trackerID = trackerID

        try? context.save()
    }

    func deleteRecord(context: NSManagedObjectContext) {
        guard let completedAt = completedAt.truncated(),
              let tracker = TrackerCoreData.fetchRecord(for: trackerID, context: context)
        else { return }

        let recordsRequest = TrackerRecordCoreData.fetchRequest()
        recordsRequest.predicate = NSPredicate(
            format: Constants.recordForTrackerPredicate,
            #keyPath(TrackerRecordCoreData.completedAt),
            completedAt as NSDate,
            #keyPath(TrackerRecordCoreData.tracker),
            tracker
        )
        if let records = try? context.fetch(recordsRequest) {
            records.forEach{context.delete($0)}
            try? context.save()
        }
    }
}

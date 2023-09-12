//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//
//

import Foundation
import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject, Identifiable {

    @NSManaged public var categoryID: UUID?
    @NSManaged public var color: String?
    @NSManaged public var emoji: String?
    @NSManaged public var isRegular: Bool
    @NSManaged public var name: String?
    @NSManaged public var schedule: String?
    @NSManaged public var trackerID: UUID?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var completed: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @nonobjc class func fetchRecord(for recordID: UUID,context: NSManagedObjectContext) -> TrackerCoreData? {

        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: ModelConstants.recordForUUIDPredicate,
            #keyPath(TrackerCoreData.trackerID),
            recordID as NSUUID
        )
        return try? context.fetch(request).first
    }
}

// MARK: Generated accessors for completed
extension TrackerCoreData {

    @objc(addCompletedObject:)
    @NSManaged public func addToCompleted(_ value: TrackerRecordCoreData)

    @objc(removeCompletedObject:)
    @NSManaged public func removeFromCompleted(_ value: TrackerRecordCoreData)

    @objc(addCompleted:)
    @NSManaged public func addToCompleted(_ values: NSSet)

    @objc(removeCompleted:)
    @NSManaged public func removeFromCompleted(_ values: NSSet)
}

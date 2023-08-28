//
//  MockDataGenerator.swift
//  Tracker
//
//  Created by Тимур Танеев on 27.08.2023.
//

import CoreData

final class MockDataGenerator {

    static func setupRecords(with context: NSManagedObjectContext?) {
        guard let context else {return}

        let checkRequest = TrackerCoreData.fetchRequest()
        let result = try! context.fetch(checkRequest)
        if result.count > 0 { return }

        struct TrackerRecord {
            let name: String
            let isRegular: Bool
            let emoji: String
            let color: String
            let schedule: String?
        }
        // Добавляем категорию 2
        let category2 = TrackerCategoryCoreData(context: context)
        category2.name = "Вторая категория, пустая"

        // Добавляем категорию 3
        let category3 = TrackerCategoryCoreData(context: context)
        category3.name = "Третья категория"

        // Добавляем категорию 1 после категории 3
        let category1 = TrackerCategoryCoreData(context: context)
        category1.name = "Первая категория"

        let tracker = TrackerCoreData(context: context)
        tracker.name = "Завершенная сегодня"
        tracker.isRegular = true
        tracker.emoji = "🙅‍♂️"
        tracker.color = "ypColorSelection-6"
        tracker.schedule = "Пн,Вт,Ср,Чт,Пт,Сб"
        tracker.category = category1

        let completed = TrackerRecordCoreData(context: context)
        completed.completedAt = Date()
        completed.tracker = tracker

        // а трекеры добавляем сначала для первой категории -
        // для проверки сортировки по категориям и трекерам
        let _ = [TrackerRecord(name: "Регулярное событие 1", isRegular: true, emoji: "🙂", color: "ypColorSelection-1", schedule: "Пн,Ср,Вс"),
                 TrackerRecord(name: "Нерегулярное событие 1", isRegular: false, emoji: "🙃", color: "ypColorSelection-2", schedule: nil),
                 TrackerRecord(name: "Регулярное событие 2", isRegular: true, emoji: "😝", color: "ypColorSelection-3", schedule: "Вт,Пн,Вс")]
            .enumerated()
            .map { index, raw in
                let tracker = TrackerCoreData(context: context)
                tracker.name = raw.name
                tracker.isRegular = raw.isRegular
                tracker.emoji = raw.emoji
                tracker.color = raw.color
                tracker.schedule = raw.schedule
                tracker.category = category1
                return tracker
        }

        // добавляем трекеры для третьей категории
        let _ = [TrackerRecord(name: "Событие третьей категории 1, регуляр", isRegular: true, emoji: "🫶", color: "ypColorSelection-4", schedule: "Пн"),
                 TrackerRecord(name: "нерегулярное событие, категория 3 ", isRegular: false, emoji: "👍", color: "ypColorSelection-5", schedule: nil)]
            .enumerated()
            .map { index, raw in
                let tracker = TrackerCoreData(context: context)
                tracker.name = raw.name
                tracker.isRegular = raw.isRegular
                tracker.emoji = raw.emoji
                tracker.color = raw.color
                tracker.schedule = raw.schedule
                tracker.category = category3
                return tracker
        }

        try! context.save()
    }
}

//
//  StatisticsStorage.swift
//  Tracker
//
//  Created by Тимур Танеев on 22.09.2023.
//

import Foundation

final class StatisticsStorage: StatisticsStorageProtocol {
    private var storage = AppData.shared

    func getBestPeriod() -> Int {
        storage.statisticsBestPeriod
    }

    func getPerfectDays() -> Int {
        storage.statisticsPerfectDays
    }

    func getTrackersCompleted() -> Int {
        storage.statisticsTrackersCount
    }

    func getAverageCompleted() -> Int {
        storage.statisticsAverageCompleted
    }
}

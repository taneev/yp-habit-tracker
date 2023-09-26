//
//  AppData.swift
//  Tracker
//
//  Created by Тимур Танеев on 05.09.2023.
//

import Foundation

enum AppDataKeys: String {
    case didStartBefore
    case statisticsTrackersCount
    case statisticsBestPeriod
    case statisticsPerfectDays
    case statisticsAverageCompleted
}

class AppData {

    static let shared = AppData()

    var isFirstAppStart: Bool {
        get {
            !UserDefaults.standard.bool(forKey: AppDataKeys.didStartBefore.rawValue)
        }
        set {
            UserDefaults.standard.setValue(!newValue, forKey: AppDataKeys.didStartBefore.rawValue)
        }
    }

    @UserDefaultsProperty(key: AppDataKeys.statisticsTrackersCount)
    var statisticsTrackersCount: Int

    @UserDefaultsProperty(key: AppDataKeys.statisticsBestPeriod)
    var statisticsBestPeriod: Int

    @UserDefaultsProperty(key: AppDataKeys.statisticsPerfectDays)
    var statisticsPerfectDays: Int

    @UserDefaultsProperty(key: AppDataKeys.statisticsAverageCompleted)
    var statisticsAverageCompleted: Int
}

//
//  AppData.swift
//  Tracker
//
//  Created by Тимур Танеев on 05.09.2023.
//

import Foundation

private enum AppDataKeys: String {
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

    @UserDefaultsProperty(key: .statisticsTrackersCount)
    var statisticsTrackersCount: Int

    @UserDefaultsProperty(key: .statisticsBestPeriod)
    var statisticsBestPeriod: Int

    @UserDefaultsProperty(key: .statisticsPerfectDays)
    var statisticsPerfectDays: Int

    @UserDefaultsProperty(key: .statisticsAverageCompleted)
    var statisticsAverageCompleted: Int
}

@propertyWrapper
final class UserDefaultsProperty {

    let storage = UserDefaults.standard
    var key: String
    var wrappedValue: Int {
        get {
            storage.integer(forKey: key)
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }

    fileprivate init(key: AppDataKeys) {
        self.key = key.rawValue
    }
}

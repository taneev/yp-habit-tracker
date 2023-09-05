//
//  AppData.swift
//  Tracker
//
//  Created by Тимур Танеев on 05.09.2023.
//

import Foundation

class AppData {

    private enum AppDataKeys {
        static let didStartBefore = "didStartBefore"
    }

    static var isFirstAppStart: Bool {
        get {
            !UserDefaults.standard.bool(forKey: AppDataKeys.didStartBefore)
        }
        set {
            UserDefaults.standard.setValue(!newValue, forKey: AppDataKeys.didStartBefore)
        }
    }
}

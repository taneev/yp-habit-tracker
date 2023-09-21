//
//  AnalyticsLogger.swift
//  Tracker
//
//  Created by Тимур Танеев on 21.09.2023.
//

import Foundation

enum LogLevel: Int, Comparable {
    case debug
    case info
    case error

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

protocol AnalyticsLoggerProtocol {
    func debug(_ message: String)
    func info(_ message: String)
    func error(_ message: String)
}

struct AnalyticsLogger: AnalyticsLoggerProtocol {
    private var level: LogLevel

    init(level: LogLevel) {
        self.level = level
    }

    func info(_ message: String) {
        if level <= .info {
            print("ANALYTICS INFO: \(message)")
        }
    }

    func debug(_ message: String) {
        if level <= .debug {
            print("ANALYTICS DEBUG: \(message)")
        }
    }

    func error(_ message: String) {
        if level <= .error {
            print("ANALYTICS ERROR: \(message)")
        }
    }
}

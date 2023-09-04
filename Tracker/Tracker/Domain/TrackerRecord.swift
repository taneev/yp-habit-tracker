//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import Foundation

/// Структура для хранения записейе о выполненных событиях
struct TrackerRecord: Hashable {
    let trackerID: UUID
    /// Дата выполнения события
    let dateCompleted: Date
}

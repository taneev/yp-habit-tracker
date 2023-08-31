//
//  Tracker.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import UIKit

/// Структура трекера привычки или нерегулярного события для слоя UI
struct Tracker {

    /// имя трекера
    let name: String

    /// тип трекера: true - регулярная привычка, false - нерегулярное событие
    let isRegular: Bool

    /// эмоджи, присвоенный трекеру
    let emoji: String

    /// цвет трекера
    let color: UIColor.YpColors?

    /// расписание трекера. Устанавливается для регулярных привычек
    let schedule: [WeekDay]?

    let isCompleted: Bool

    let completedCounter: Int

}

//
//  Tracker.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import UIKit

/// Структура для хранения трекера привычки или нерегулярного события
struct Tracker {

    /// имя трекера
    let name: String

    /// тип трекера: true - регулярная привычка, false - нерегулярное событие
    let isRegular: Bool

    /// эмоджи, присвоенный трекеру
    let emoji: String

    /// цвет трекера
    let color: UIColor

    /// расписание трекера. Устанавливается для регулярных привычек
    let schedule: [WeekDay]?
}

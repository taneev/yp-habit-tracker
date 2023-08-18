//
//  TextHelper.swift
//  Tracker
//
//  Created by Тимур Танеев on 09.08.2023.
//

import Foundation

final class TextHelper {
    static func getDaysText(for daysNumber: Int) -> String {
        let lastDigit = daysNumber % 10
        let reminder100 = daysNumber % 100
        if lastDigit == 1 && reminder100 != 11 {
            return "день"
        } else if lastDigit >= 2 && lastDigit <= 4 && (reminder100 < 10 || reminder100 >= 20) {
            return "дня"
        } else {
            return "дней"
        }
    }
}

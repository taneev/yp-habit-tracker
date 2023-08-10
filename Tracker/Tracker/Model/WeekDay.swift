//
//  WeekDay.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case sun = 1, // для соответствия григорианскому календарю в Calendar,
                  // другие календари не поддерживаются
         mon, tue, wed, thu, fri, sat
}

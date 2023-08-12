//
//  Tracker.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import UIKit

struct Tracker {
    let trackerID = UUID()
    let name: String
    let isRegular: Bool
    let emoji: String
    let color: UIColor
    let schedule: [WeekDay]?
}

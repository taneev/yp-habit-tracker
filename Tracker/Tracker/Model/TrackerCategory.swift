//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Тимур Танеев on 07.08.2023.
//

import Foundation

struct TrackerCategory {
    let categoryID = UUID()
    let name: String
    let activeTrackers: [Tracker]?
    let completedTrackers: [Tracker]? = nil
}

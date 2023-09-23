//
//  ServiceAnalyticsProtocol.swift
//  Tracker
//
//  Created by Тимур Танеев on 21.09.2023.
//

protocol ServiceAnalyticsProtocol {
    func report(
        event eventType: AnalyticsEventType,
        screen screenType: AnalyticsScreenType,
        item itemType: AnalyticsItemType?
    )
}

enum AnalyticsEventType: String {
    case open, close, click
}

enum AnalyticsScreenType: String {
    case main
}

enum AnalyticsItemType: String {
    case track, filter, edit, delete
    case addTrack = "add_track"
}

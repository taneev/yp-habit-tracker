//
//  ServiceAnalytics.swift
//  Tracker
//
//  Created by Тимур Танеев on 21.09.2023.
//

import Foundation
import os
import YandexMobileMetrica

final class ServiceAnalytics: ServiceAnalyticsProtocol {
    static var shared = ServiceAnalytics(isLoggingEnable: true)
    private var isLoggingEnable: Bool
    private let logger: AnalyticsLoggerProtocol

    init(isLoggingEnable: Bool, logger: AnalyticsLoggerProtocol = AnalyticsLogger(level: .info)) {
        self.isLoggingEnable = isLoggingEnable
        self.logger = logger
    }

    func report(
        event eventType: AnalyticsEventType,
        screen screenType: AnalyticsScreenType,
        item itemType: AnalyticsItemType? = nil
    ) {
        logger.debug("report call for event: \(eventType), screen: \(screenType), item: \(itemType?.rawValue ?? "nil")")
        var params: [AnyHashable: Any] = [
            "event": eventType.rawValue,
            "screen": screenType.rawValue
        ]

        if eventType == .click {
            if let itemType {
                params["item"] = itemType.rawValue
            } else {
                logger.error("No items for click event, screen \(screenType.rawValue)")
            }
        }

        let event = itemType?.rawValue ?? eventType.rawValue
        logger.info("report call for event: \(event), params: \(params)")
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { [weak self] error in
            self?.logger.error("report failed with error: \(error.localizedDescription)")
        })
    }
}

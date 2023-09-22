//
//  StatisticsStorageProtocol.swift
//  Tracker
//
//  Created by Тимур Танеев on 22.09.2023.
//

import Foundation

protocol StatisticsStorageProtocol{
    func getBestPeriod() -> Int
    func getPerfectDays() -> Int
    func getTrackersCompleted() -> Int
    func getAverageCompleted() -> Int
}

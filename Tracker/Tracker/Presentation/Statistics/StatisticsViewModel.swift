//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 23.09.2023.
//

final class StatisticsViewModel: StatisticsViewModelProtocol {

    @Observable private var bestPeriod: Int = 0
    @Observable private var perfectDays: Int = 0
    @Observable private var trackersCompleted: Int = 0
    @Observable private var averageCompleted: Int = 0
    @Observable private var isStatisticsPresenting: Bool = false

    private var statisticsStorage: StatisticsStorageProtocol
    private var isStatisticsAvailable: Bool {
        !(bestPeriod == 0 && perfectDays == 0 && trackersCompleted == 0 && averageCompleted == 0)
    }

    init(statisticsStorage: StatisticsStorageProtocol) {
        self.statisticsStorage = statisticsStorage
    }

    func viewWillAppear() {
        getActualStatistics()
        isStatisticsPresenting = isStatisticsAvailable
    }

    func setBindings(_ bindings: StatisticsViewModelBindings) {
        self.$bestPeriod.bind(action: bindings.bestPeriod)
        self.$perfectDays.bind(action: bindings.perfectDays)
        self.$trackersCompleted.bind(action: bindings.trackersCompleted)
        self.$averageCompleted.bind(action: bindings.averageCompleted)
        self.$isStatisticsPresenting.bind(action: bindings.isStatisticsPresenting)
    }

    private func getActualStatistics() {
        bestPeriod = statisticsStorage.getBestPeriod()
        perfectDays = statisticsStorage.getPerfectDays()
        trackersCompleted = statisticsStorage.getTrackersCompleted()
        averageCompleted = statisticsStorage.getAverageCompleted()
    }
}

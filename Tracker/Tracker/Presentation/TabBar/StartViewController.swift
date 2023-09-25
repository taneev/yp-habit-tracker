//
//  StartViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 17.09.2023.
//

import UIKit

final class StartViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barStyle = .default
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .ypWhiteDay
        tabBar.layer.borderWidth = 1
        updateTabBarBorderColor()

        let statisticsStorage = StatisticsStorage()
        let trackersListViewController = TrackersViewController()
        trackersListViewController.analytics = AnalyticsService.shared
        let dataProvider = TrackerDataProvider(
            delegate: trackersListViewController,
            statisticsStorage: statisticsStorage
        )
        trackersListViewController.dataProvider = dataProvider
        // Загрузка мок-данных в БД для проверки функциональности на ревью
        MockDataGenerator.setupRecords(with: dataProvider)

        let trackersTabBarImage = UIImage(named: "record.circle.fill") ?? UIImage()
        trackersListViewController.tabBarItem = UITabBarItem(
            title: "tabBar.trackers".localized(),
            image: trackersTabBarImage,
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let viewModel = StatisticsViewModel(statisticsStorage: statisticsStorage)
        statisticsViewController.viewModel = viewModel
        let statisticsTabBarImage = UIImage(systemName: "hare.fill") ?? UIImage()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "tabBar.statistics".localized(),
            image: statisticsTabBarImage,
            selectedImage: nil
        )
        setViewControllers([trackersListViewController, statisticsViewController], animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTabBarBorderColor()
    }

    private func updateTabBarBorderColor() {
        if #available(iOS 13.0, *) {
            tabBar.layer.borderColor = traitCollection.userInterfaceStyle == .light
            ? UIColor.ypGray.cgColor
            : UIColor.ypWhiteDay.cgColor
        }
    }
}

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

        let trackersListViewController = TrackersViewController()
        let trackersTabBarImage = UIImage(named: "record.circle.fill") ?? UIImage()
        trackersListViewController.tabBarItem = UITabBarItem(
                title: "Трекеры",
                image: trackersTabBarImage,
                selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let statisticsTabBarImage = UIImage(systemName: "hare.fill") ?? UIImage()
        statisticsViewController.tabBarItem = UITabBarItem(
                title: "Статистика",
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

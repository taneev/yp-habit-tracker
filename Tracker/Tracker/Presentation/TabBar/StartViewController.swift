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
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBar.layer.borderWidth = 1

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
}

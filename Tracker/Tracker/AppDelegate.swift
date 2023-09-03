//
//  AppDelegate.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()

        createInitialViewControllers()
        return true
    }

    private func createInitialViewControllers() {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barStyle = .default
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = .ypWhiteDay
        tabBarController.tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBarController.tabBar.layer.borderWidth = 1

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

        tabBarController.setViewControllers([trackersListViewController, statisticsViewController], animated: true)
        window?.rootViewController = tabBarController
    }
}


//
//  AppDelegate.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initializing the AppMetrica SDK.
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "fcde4204-33c4-4a7e-bce1-a7e8e19fafb7")
        YMMYandexMetrica.activate(with: configuration!)

        window = UIWindow()
        window?.makeKeyAndVisible()

        if AppData.shared.isFirstAppStart {
            AppData.shared.isFirstAppStart = false
            let onboardingViewController = OnboardingViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil
            )
            window?.rootViewController = onboardingViewController
        } else {
            window?.rootViewController = StartViewController()
        }
        return true
    }
}

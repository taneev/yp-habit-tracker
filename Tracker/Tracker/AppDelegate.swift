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

        if AppData.isFirstAppStart {
            AppData.isFirstAppStart = false
            let onboardingViewController = OnboardingViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil
            )
            window?.rootViewController = onboardingViewController
        }
        else {
            window?.rootViewController = StartViewController()
        }
        return true
    }
}


//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 05.09.2023.
//

import UIKit

class OnboardingViewController: UIPageViewController {

    private enum Constants {
        static let onboardingImageNamePage1 = "onboarding1"
        static let onboardingImageNamePage2 = "onboarding2"
    }

    private lazy var pages = { createPageViewControllers() }()
    private lazy var pageControl: UIPageControl = { createPageControl() }()
    private lazy var startButton = RoundedButton(title: "Вот это технологии!")

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true)
        }
        startButton.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
        addSubviews()
    }

    @objc private func startButtonDidTap() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window
        else { return }
        let startViewController = appDelegate.startViewController
        window.rootViewController = startViewController
    }

    private func createPageViewControllers() -> [UIViewController] {
        let page1 = OnboardingPageViewController()
        page1.backgroundImageName = Constants.onboardingImageNamePage1
        page1.pageMainMessage = "Отслеживайте только то, что хотите"

        let page2 = OnboardingPageViewController()
        page2.backgroundImageName = Constants.onboardingImageNamePage2
        page2.pageMainMessage = "Даже если это не литры воды и йога"
        return [page1, page2]
    }
}

// MARK: Setup & Layout UI

private extension OnboardingViewController {

    func createPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = .zero

        pageControl.currentPageIndicatorTintColor = .ypBlackDay
        pageControl.pageIndicatorTintColor = .ypBlackDay.withAlphaComponent(0.3)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }

    func addSubviews() {
        view.addSubview(pageControl)
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {

        guard let viewControllerIndex = pages.firstIndex(of: viewController),
              viewControllerIndex > 0
        else {
            return nil
        }
        return pages[viewControllerIndex - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {

        guard let viewControllerIndex = pages.firstIndex(of: viewController),
              viewControllerIndex < pages.count - 1
        else {
            return nil
        }
        return pages[viewControllerIndex + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}


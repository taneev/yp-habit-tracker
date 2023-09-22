//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {

    private lazy var placeholderView = { createPlaceholderView() }()
    private lazy var trackersCompletedView = { createTrackersCompletedView() }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

// MARK: Setup & Layout UI

private extension StatisticsViewController {

    func createPlaceholderView() -> PlaceholderView {
        let view = PlaceholderView()
        view.placeholderText = "Анализировать пока нечего"
        view.placeholderImage = UIImage(named: "emptyStat")
        return view
    }

    func createTrackersCompletedView() -> StatisticView {
        let view = StatisticView()
        view.statisticValue = 0
        view.statisticName = "Трекеров завершено"
        return view
    }

    func setupUI() {
        view.backgroundColor = .ypWhiteDay

        let title = UILabel()
        title.text = "Статистика"
        title.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        title.textColor = .ypBlackDay
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])

        view.addSubview(placeholderView)
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.addSubview(trackersCompletedView)
        NSLayoutConstraint.activate([
            trackersCompletedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCompletedView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 77),
            trackersCompletedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

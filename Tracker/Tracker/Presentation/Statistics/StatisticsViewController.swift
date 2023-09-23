//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 12.08.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {

    var viewModel: StatisticsViewModelProtocol? {
        didSet {
            if viewModel == nil { return }
            bind()
        }
    }

    private lazy var placeholderView = { createPlaceholderView() }()
    private lazy var bestPeriodView = { createBestPeriodView() }()
    private lazy var perfectDaysView = { createPerfectDaysView() }()
    private lazy var trackersCompletedView = { createTrackersCompletedView() }()
    private lazy var averageCompletedView = { createAverageCompletedView() }()
    private lazy var statisticsView = { createStatisticsStack() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }

    private func bind() {
        let bindings = StatisticsViewModelBindings(
            bestPeriod: { [weak self] in
                self?.bestPeriodView.statisticValue = $0
            },
            perfectDays: { [weak self] in
                self?.perfectDaysView.statisticValue = $0
            },
            trackersCompleted: { [weak self] in
                self?.trackersCompletedView.statisticValue = $0
            },
            averageCompleted: { [weak self] in
                self?.averageCompletedView.statisticValue = $0
            },
            isStatisticsPresenting: { [weak self] in
                guard let self else { return }
                if $0 {
                    self.placeholderView.isHidden = true
                    self.statisticsView.isHidden = false
                }
                else {
                    self.placeholderView.isHidden = false
                    self.statisticsView.isHidden = true
                }
            })
        viewModel?.setBindings(bindings)
    }
}

// MARK: Setup & Layout UI

private extension StatisticsViewController {

    func createPlaceholderView() -> PlaceholderView {
        let view = PlaceholderView()
        view.placeholderText = "statistics.placeholderText".localized()
        view.placeholderImage = UIImage(named: "emptyStat")
        return view
    }

    func createBestPeriodView() -> StatisticView {
        let view = StatisticView()
        view.statisticName = "statistics.bestPeriod".localized()
        return view
    }

    func createPerfectDaysView() -> StatisticView {
        let view = StatisticView()
        view.statisticName = "statistics.perfectDays".localized()
        return view
    }

    func createTrackersCompletedView() -> StatisticView {
        let view = StatisticView()
        view.statisticName = "statistics.trackersCompleted".localized()
        return view
    }

    func createAverageCompletedView() -> StatisticView {
        let view = StatisticView()
        view.statisticName = "statistics.averageCompleted".localized()
        return view
    }

    func createStatisticsStack() -> UIStackView {
        let view = UIStackView(
            arrangedSubviews: [bestPeriodView, perfectDaysView, trackersCompletedView, averageCompletedView]
        )
        view.axis = .vertical
        view.spacing = 12
        view.distribution = .fillEqually
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func setupUI() {
        view.backgroundColor = .ypWhiteDay

        let title = UILabel()
        title.text = "statistics.title".localized()
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

        view.addSubview(statisticsView)
        NSLayoutConstraint.activate([
            statisticsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 77),
            statisticsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit

protocol TrackersBarControllerProtocol: AnyObject, UISearchBarDelegate {
    func addTrackerButtonDidTapped()
    func currentDateDidChange(for selectedDate: Date)
}

final class TrackersViewController: UIViewController {

    var categories: [TrackerCategory] = [
        TrackerCategory(categoryID: UUID(),
                        name: "Домашний уют",
                        activeTrackers: [
                            Tracker(name: "Поливать растения",
                                    isRegular: true,
                                    emoji: "❤️",
                                    color: .ypColorSelection5,
                                    counter: 0,
                                    schedule: [.mon, .tue]),
                            Tracker(name: "Постричь газон во дворе",
                                    isRegular: false,
                                    emoji: "🏝️",
                                    color: .ypColorSelection2,
                                    counter: 21,
                                    schedule: nil),
                            Tracker(name: "Постирать шторы",
                                    isRegular: true,
                                    emoji: "🤔",
                                    color: .ypColorSelection15,
                                    counter: 2,
                                    schedule: [.sun]),
                        ]),
        TrackerCategory(categoryID: UUID(),
                        name: "Занятия спортом",
                        activeTrackers: nil),
        TrackerCategory(categoryID: UUID(),
                        name: "Радостные мелочи",
                        activeTrackers: [
                            Tracker(name: "Кошка заслонила камеру на созвоне",
                                    isRegular: true,
                                    emoji: "😻",
                                    color: .ypColorSelection3,
                                    counter: 5,
                                    schedule: nil),
                            Tracker(name: "Бабушка прислала открытку в телеге!",
                                    isRegular: true,
                                    emoji: "❤️",
                                    color: .ypColorSelection1,
                                    counter: 23,
                                    schedule: [.fri, .sat, .tue, .mon]),
                            Tracker(name: "Дать свиньям",
                                    isRegular: false,
                                    emoji: "🐶",
                                    color: .ypColorSelection18,
                                    counter: 23780,
                                    schedule: Array(WeekDay.allCases)),
                        ]),
        TrackerCategory(categoryID: UUID(),
                        name: "Самочуствие",
                        activeTrackers: []),

    ]
    var visibleCategories: [TrackerCategory]?
    var completedTrackers: Set<TrackerRecord>?

    private var currentDate: Date = Date()
    private var searchBarTextFilter: String = ""

    private lazy var navigationBar = { createNavigationBar() }()
    private lazy var collectionView = { createCollectionView() }()
    private lazy var emptyCollectionPlaceholder = { EmptyCollectionPlaceholderView() }()

    private let params = GeometricParams(cellCount: 2,
                                         leftInset: 16,
                                         rightInset: 16,
                                         cellSpacing: 9)

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        addConstraints()
        filterVisibleCategories()
        collectionView.reloadData()
        if categories.isEmpty {
            emptyCollectionPlaceholder.isHidden = false
        }
        else {
            emptyCollectionPlaceholder.isHidden = true
        }
    }

    private func filterVisibleCategories() {
        let categoriesFilteredByDate = categories.compactMap{ category -> TrackerCategory? in
            guard let activeTrackers = category.activeTrackers else { return nil }

            let visibleTrackers = activeTrackers.filter{ tracker in
                if !tracker.isRegular {
                    return true
                }

                guard let schedule = tracker.schedule
                else { // регулярная привычка с почему-то не заданным расписанием
                       // - отображать всегда или никогда?
                       // отображаю всегда, чтобы был шанс исправить ошибку (в расписании или коде)
                    return true
                }

                if let currentWeekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: currentDate)) {
                    return schedule.contains(currentWeekDay)
                }
                return false
            }

            if visibleTrackers.isEmpty {
                return nil
            }
            let filteredCategory = TrackerCategory(categoryID: category.categoryID,
                                                   name: category.name,
                                                   activeTrackers: visibleTrackers,
                                                   completedTrackers: category.completedTrackers)

            return filteredCategory
        }

        visibleCategories = categoriesFilteredByDate
    }
}

// MARK: Layout
private extension TrackersViewController {

    func createNavigationBar() -> UINavigationBar {
        let bar = TrackerNavigationBar(frame: .zero,
                                       trackerBarDelegate: self)
        return bar
    }

    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.cellIdentifier)
        collectionView.register(TrackersSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackersSectionHeaderView.viewIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    func addSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(collectionView)
        view.addSubview(emptyCollectionPlaceholder)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyCollectionPlaceholder.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyCollectionPlaceholder.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
}

// MARK: Navigation bar delegate
extension TrackersViewController: TrackersBarControllerProtocol {
    func currentDateDidChange(for selectedDate: Date) {
        currentDate = selectedDate
        filterVisibleCategories()
        collectionView.reloadData()
    }

    func addTrackerButtonDidTapped() {
        print("add Tracker tapped")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarTextFilter = searchText.trimmingCharacters(in: .whitespaces)
        print("txt filter: \(searchBarTextFilter)")
        collectionView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarTextFilter = ""
        print("txt filter cancelled")
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories?[section].activeTrackers?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.cellIdentifier, for: indexPath) as? TrackerViewCell,
              let currentCategory = visibleCategories?[indexPath.section],
              let tracker = currentCategory.activeTrackers?[indexPath.row]
        else {return UICollectionViewCell()}

        cell.cellName = tracker.name
        cell.cellColor = tracker.color
        cell.emoji = tracker.emoji
        cell.isCompleted = false
        cell.quantity = tracker.counter
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(width: (collectionView.frame.width - params.paddingWidth) / CGFloat(params.cellCount), height: 90 + TrackerViewCell.quantityCardHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        UIEdgeInsets(top: 16, left: params.leftInset, bottom: 12, right: params.rightInset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
           let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                      withReuseIdentifier: TrackersSectionHeaderView.viewIdentifier,
                                                                      for: indexPath) as? TrackersSectionHeaderView {
            view.headerLabel.text = visibleCategories?[indexPath.section].name ?? ""
            return view
        }
        else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: 18)
    }
}

private struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat

    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit

protocol TrackersBarControllerProtocol: AnyObject {
    func addTrackerButtonDidTapped()
    func currentDateDidChange(for selectedDate: Date)
}

protocol NewTrackerSaverDelegate: AnyObject {
    func save(tracker: Tracker, in categoryID: UUID)
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
                                    schedule: [.mon, .tue]),
                            Tracker(name: "Постричь газон во дворе",
                                    isRegular: false,
                                    emoji: "🏝️",
                                    color: .ypColorSelection2,
                                    schedule: nil),
                            Tracker(name: "Постирать шторы",
                                    isRegular: true,
                                    emoji: "🤔",
                                    color: .ypColorSelection15,
                                    schedule: [.sun]),
                        ]),
        TrackerCategory(categoryID: UUID(uuidString: "8BFB9644-098E-46CF-9C47-BF3740038E1C")!,
                        name: "Занятия спортом",
                        activeTrackers: nil),
        TrackerCategory(categoryID: UUID(),
                        name: "Радостные мелочи",
                        activeTrackers: [
                            Tracker(name: "Кошка заслонила камеру на созвоне",
                                    isRegular: true,
                                    emoji: "😻",
                                    color: .ypColorSelection3,
                                    schedule: nil),
                            Tracker(name: "Бабушка прислала открытку в телеге!",
                                    isRegular: true,
                                    emoji: "❤️",
                                    color: .ypColorSelection1,
                                    schedule: [.fri, .sat, .tue, .mon]),
                            Tracker(name: "Дать свиньям",
                                    isRegular: false,
                                    emoji: "🐶",
                                    color: .ypColorSelection18,
                                    schedule: Array(WeekDay.allCases)),
                        ]),
        TrackerCategory(categoryID: UUID(),
                        name: "Самочуствие",
                        activeTrackers: []),

    ]
    var completedTrackers: [TrackerRecord] = []
    var visibleCategories: [TrackerCategory] = []
    private var completedTrackersIDs: Set<UUID> = Set()
    private var completedTrackersCounter: [UUID: Int] = [:]

    private var currentDate: Date = Date()
    private var searchTextFilter: String = ""

    private lazy var navigationBar = { createNavigationBar() }()
    private lazy var searchTextField = { createSearchTextField() }()
    private lazy var collectionView = { createCollectionView() }()
    private lazy var emptyCollectionPlaceholder = { EmptyCollectionPlaceholderView() }()

    private let params = GeometricParams(cellCount: 2,
                                         leftInset: 16,
                                         rightInset: 16,
                                         cellSpacing: 9)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhiteDay
        addSubviews()
        addConstraints()
        loadData()

        // Для скрытия курсора с поля ввода при тапе вне поля ввода и вне клавиатуры
        let anyTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAnyTap))
        view.addGestureRecognizer(anyTapGesture)
    }

    @objc private func handleAnyTap(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }

    private func loadData() {
        completedTrackersIDs = selectCompletedTrackersIDs(for: currentDate)
        initCompletedCounters()
        filterVisibleCategories()
        collectionView.reloadData()
    }

    private func initCompletedCounters() {
        for record in completedTrackers {
            completedTrackersCounter[record.trackerID] = (completedTrackersCounter[record.trackerID] ?? 0) + 1
        }
    }

    private func isPassedDate(_ date: Date, filter schedule: [WeekDay]?) -> Bool {
        guard let schedule
        else { // регулярная привычка с почему-то не заданным расписанием
               // - отображать всегда или никогда?
               // отображаю всегда, чтобы был шанс исправить ошибку (в расписании или коде)
            return true
        }

        if let currentWeekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: date)) {
            return schedule.contains(currentWeekDay)
        }
        return false
    }

    private func isPassedName(_ name: String, filter searchText: String) -> Bool {
        return searchText.isEmpty || name.lowercased().contains(searchText.lowercased())
    }

    private func filterVisibleCategories() {
        let categoriesFiltered = categories.compactMap{ category -> TrackerCategory? in
            guard let activeTrackers = category.activeTrackers else { return nil }

            let visibleTrackers = activeTrackers.filter{
                (!$0.isRegular || isPassedDate(currentDate, filter: $0.schedule)) && isPassedName($0.name, filter: searchTextFilter)
            }

            if visibleTrackers.isEmpty {
                return nil
            }
            let filteredCategory = TrackerCategory(categoryID: category.categoryID,
                                                   name: category.name,
                                                   activeTrackers: visibleTrackers)

            return filteredCategory
        }
        visibleCategories = categoriesFiltered
        updatePlaceholderType()
    }

    private func isTrackerCompleted(withId trackerID: UUID) -> Bool {
        return completedTrackersIDs.contains(trackerID)
    }

    private func completeTracker(withID trackerID: UUID) {
        let record = TrackerRecord(trackerID: trackerID, dateCompleted: currentDate)
        completedTrackers.append(record)
        completedTrackersIDs.insert(trackerID)
        completedTrackersCounter[trackerID] = (completedTrackersCounter[trackerID] ?? 0) + 1
    }

    private func uncompleteTracker(withID trackerID: UUID) {
        if completedTrackersIDs.contains(trackerID) {
            completedTrackersIDs.remove(trackerID)
            if let counter = completedTrackersCounter[trackerID],
                counter > 1 {
                completedTrackersCounter[trackerID] = counter - 1
            }
            else {
                completedTrackersCounter.removeValue(forKey: trackerID)
            }
        }

        for (i, record) in completedTrackers.enumerated() {
            let order = Calendar.current.compare(currentDate,
                                                 to: record.dateCompleted,
                                                 toGranularity: .day)
            if order == .orderedSame {
                completedTrackers.remove(at: i)
                break
            }
        }
    }

    private func selectCompletedTrackersIDs(for selectionDate: Date) -> Set<UUID> {
        var completedTrackersIDs = Set<UUID>()
        for record in completedTrackers {
            if Calendar.current.compare(record.dateCompleted, to: selectionDate, toGranularity: .day) == .orderedSame {
                completedTrackersIDs.insert(record.trackerID)
            }
        }
        return completedTrackersIDs
    }

    private func getCompletedTrackersCount(for trackerID: UUID) -> Int {
        completedTrackersCounter[trackerID] ?? 0
    }

    private func save(_ tracker: Tracker, in categoryID: UUID) {
        var categoryIndexForUpdate: Int?
        for (i, category) in categories.enumerated() {
            if category.categoryID == categoryID {
                categoryIndexForUpdate = i
                break
            }
        }
        guard let categoryIndexForUpdate else {
            assertionFailure("Не удалось сохранить трекер в категории \(categoryID)")
            return
        }
        categories[categoryIndexForUpdate] = TrackerCategory(
            categoryID: categoryID,
            name: categories[categoryIndexForUpdate].name,
            activeTrackers: (categories[categoryIndexForUpdate].activeTrackers ?? []) + [tracker]
        )
    }
}

extension TrackersViewController: NewTrackerSaverDelegate {
    func save(tracker: Tracker, in categoryID: UUID) {
        save(tracker, in: categoryID)
        filterVisibleCategories()
        collectionView.reloadData()
        dismiss(animated: true)
    }
}

// MARK: TrackerViewCellDelegate
extension TrackersViewController: TrackerViewCellProtocol {
    func trackerDoneButtonDidTapped(for trackerID: UUID) {
        if isTrackerCompleted(withId: trackerID) {
            uncompleteTracker(withID: trackerID)
        }
        else {
            completeTracker(withID: trackerID)
        }
    }

    func trackerCounterValue(for trackerID: UUID) -> Int {
        return getCompletedTrackersCount(for: trackerID)
    }

}

// MARK: Navigation bar delegate
extension TrackersViewController: TrackersBarControllerProtocol {
    func currentDateDidChange(for selectedDate: Date) {
        currentDate = selectedDate
        completedTrackersIDs = selectCompletedTrackersIDs(for: currentDate)
        filterVisibleCategories()
        collectionView.reloadData()
    }

    func addTrackerButtonDidTapped() {
        searchTextField.resignFirstResponder()
        let selectTrackerTypeViewController = CreateTrackerTypeSelectionViewController()
        selectTrackerTypeViewController.saverDelegate = self
        selectTrackerTypeViewController.modalPresentationStyle = .automatic
        present(selectTrackerTypeViewController, animated: true)
    }
}

// MARK: Search text delegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchTextFilter = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        filterVisibleCategories()
        collectionView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
    }
}

// MARK: UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].activeTrackers?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.cellIdentifier, for: indexPath) as? TrackerViewCell,
              let tracker = visibleCategories[indexPath.section].activeTrackers?[indexPath.row]
        else {return UICollectionViewCell()}

        cell.delegate = self
        cell.trackerID = tracker.trackerID
        cell.cellName = tracker.name
        cell.cellColor = tracker.color
        cell.emoji = tracker.emoji
        cell.isCompleted = isTrackerCompleted(withId: tracker.trackerID)
        cell.quantity = getCompletedTrackersCount(for: tracker.trackerID)

        let order = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day)
        cell.isDoneButtonEnabled = !(order == .orderedAscending)
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
            view.headerLabel.text = visibleCategories[indexPath.section].name
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

// MARK: Layout
private extension TrackersViewController {

    func createSearchTextField() -> UISearchTextField {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
        searchField.delegate = self
        searchField.font = UIFont.systemFont(ofSize: 17)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }

    func createNavigationBar() -> TrackerNavigationBar {
        let bar = TrackerNavigationBar(frame: .zero, trackerBarDelegate: self)
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
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        addPlaceholder()
    }

    func updatePlaceholderType() {
        if categories.isEmpty {
            emptyCollectionPlaceholder.isHidden = false
            emptyCollectionPlaceholder.placeholderType = .noData
        }
        else if visibleCategories.isEmpty {
            emptyCollectionPlaceholder.isHidden = false
            emptyCollectionPlaceholder.placeholderType = .emptyList
        }
        else {
            emptyCollectionPlaceholder.isHidden = true
        }
    }

    func addPlaceholder() {
        view.addSubview(emptyCollectionPlaceholder)
        updatePlaceholderType()
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 7),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyCollectionPlaceholder.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyCollectionPlaceholder.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
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

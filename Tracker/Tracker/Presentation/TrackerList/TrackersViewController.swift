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

    private lazy var dataProvider: DataProviderProtocol? = { createDataProvider() }()

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

    private func createDataProvider() -> DataProvider {
        return DataProvider()
    }

    private func loadData() {
        dataProvider?.loadData()
        collectionView.reloadData()
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

    private func hasCompletedRecords(at indexPath: IndexPath, for date: Date) -> Bool {
        dataProvider?.hasCompletedRecords(at: indexPath, for: date) ?? false
    }

    private func completeTracker(at indexPath: IndexPath, for date: Date) {
        dataProvider?.completeTracker(at: indexPath, for: date)
    }

    private func uncompleteTracker(at indexPath: IndexPath, for date: Date) {
        dataProvider?.uncompleteTracker(at: indexPath, for: date)
    }

    private func getCompletedTrackersCount(at indexPath: IndexPath, for date: Date) -> Int {
        dataProvider?.getCompletedTrackersCount(at: indexPath, for: date) ?? 0
    }

}

extension TrackersViewController: NewTrackerSaverDelegate {
    func save(tracker: Tracker, in categoryID: UUID) {
        dataProvider?.save(tracker: tracker, in: categoryID)
        collectionView.reloadData()
        dismiss(animated: true)
    }
}

// MARK: TrackerViewCellDelegate
extension TrackersViewController: TrackerViewCellProtocol {
    func trackerDoneButtonDidTapped(at indexPath: IndexPath) {
        if hasCompletedRecords(at: indexPath, for: currentDate) {
            uncompleteTracker(at: indexPath, for: currentDate)
        }
        else {
            completeTracker(at: indexPath, for: currentDate)
        }
    }

    func trackerCounterValue(at indexPath: IndexPath) -> Int {
        return getCompletedTrackersCount(at: indexPath, for: currentDate)
    }
}

// MARK: Navigation bar delegate
extension TrackersViewController: TrackersBarControllerProtocol {
    func currentDateDidChange(for selectedDate: Date) {
        currentDate = selectedDate
        dataProvider?.updateFilterWith(selectedDate: selectedDate, searchString: searchTextFilter)
        collectionView.reloadData()
    }

    func addTrackerButtonDidTapped() {
        searchTextField.resignFirstResponder()
        let selectTrackerTypeViewController = CreateTrackerTypeSelectionViewController()
        selectTrackerTypeViewController.saverDelegate = self
        selectTrackerTypeViewController.dataProvider = dataProvider
        selectTrackerTypeViewController.modalPresentationStyle = .automatic
        present(selectTrackerTypeViewController, animated: true)
    }
}

// MARK: Search text delegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchTextFilter = textField.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        dataProvider?.updateFilterWith(selectedDate: currentDate, searchString: searchTextFilter)
        collectionView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
    }
}

// MARK: UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataProvider?.numberOfSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider?.numberOfRows(in: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.cellIdentifier, for: indexPath) as? TrackerViewCell,
              let tracker = dataProvider?.object(at: indexPath)
        else {return UICollectionViewCell()}
        cell.delegate = self
        cell.indexPath = indexPath
        cell.tracker = tracker
        cell.isCompleted = hasCompletedRecords(at: indexPath, for: currentDate)
        cell.quantity = getCompletedTrackersCount(at: indexPath, for: currentDate)
        cell.isDoneButtonEnabled = !currentDate.isGreater(than: Date())
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
           let view = collectionView.dequeueReusableSupplementaryView(
                            ofKind: kind,
                            withReuseIdentifier: TrackersSectionHeaderView.viewIdentifier,
                            for: indexPath
                ) as? TrackersSectionHeaderView {
            view.headerLabel.text = dataProvider?.getCategoryNameForObject(at: indexPath)
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
//        if categories.isEmpty {
//            emptyCollectionPlaceholder.isHidden = false
//            emptyCollectionPlaceholder.placeholderType = .noData
//        }
//        else if visibleCategories.isEmpty {
//            emptyCollectionPlaceholder.isHidden = false
//            emptyCollectionPlaceholder.placeholderType = .emptyList
//        }
//        else {
            emptyCollectionPlaceholder.isHidden = true
//        }
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
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
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

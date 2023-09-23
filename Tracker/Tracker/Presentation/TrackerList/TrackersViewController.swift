//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdateIndexPath(_ updatedIndexes: UpdatedIndexes)
}

protocol TrackersBarControllerProtocol: AnyObject {
    func addTrackerButtonDidTapped()
    func currentDateDidChange(for selectedDate: Date)
}

protocol NewTrackerSaverDelegate: AnyObject {
    func save(tracker: Tracker, in category: TrackerCategory)
}

protocol FilterSelectionDelegate: AnyObject {
    func filterDidSelect(_ filterKind: FilterItemKind)
}

final class TrackersViewController: UIViewController {

    var analytics: ServiceAnalyticsProtocol?
    var dataProvider: (any TrackerDataProviderProtocol)?

    private var currentDate: Date = Date()
    private var searchTextFilter: String = ""
    private var filterSelected: FilterItemKind?

    private var isFilterButtonHidden: Bool = true {
        didSet {
            filterButton.isHidden = isFilterButtonHidden
        }
    }

    private lazy var navigationBar = { createNavigationBar() }()
    private lazy var searchTextField = { createSearchTextField() }()
    private lazy var collectionView = { createCollectionView() }()
    private lazy var emptyCollectionPlaceholder = { EmptyCollectionPlaceholderView() }()
    private lazy var filterButton = { createFilterButton() }()

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics?.report(event: .open, screen: .main, item: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics?.report(event: .close, screen: .main, item: nil)
    }

    @objc private func handleAnyTap(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }

    @objc private func filterButtonDidTap() {
        analytics?.report(event: .click, screen: .main, item: .filter)
        let controller = TrackersFilterViewController()
        controller.modalPresentationStyle = .automatic
        controller.filterSelectionDelegate = self
        controller.selectedItem = filterSelected
        present(controller, animated: true)
    }

    private func updateFilterButtonState() {
        isFilterButtonHidden = dataProvider?.getNumberOfTrackers(for: currentDate) == 0
    }

    private func loadData() {
        dataProvider?.setDateFilter(with: currentDate)
        dataProvider?.loadData()
        collectionView.reloadData()
        updatePlaceholderType()
        updateFilterButtonState()
    }

    private func isPinnedSection(_ section: Int) -> Bool {
        section == 0
    }
}

// MARK: NewTrackerSaverDelegate

extension TrackersViewController: NewTrackerSaverDelegate {
    func save(tracker: Tracker, in category: TrackerCategory) {
        dataProvider?.save(tracker: tracker, in: category)
        dismiss(animated: true)
    }
}

// MARK: FilterSelectionDelegate

extension  TrackersViewController: FilterSelectionDelegate {
    func filterDidSelect(_ filterKind: FilterItemKind) {
        // Фильтр "Трекеры на сегодня" не сохраняет состояние фильтра по "завершенности",
        // а только меняет текущую дату и переключает на нее фильтр
        filterSelected = filterKind == .today ? filterSelected : filterKind
        switch filterKind {
        case .today:
            let today = Date()
            navigationBar.setDatePickerDate(to: today)
            currentDateDidChange(for: today)
        case .completed:
            dataProvider?.setCompletedFilter(with: true)
        case .todo:
            dataProvider?.setCompletedFilter(with: false)
        case .all:
            dataProvider?.setCompletedFilter(with: nil)
        }
        collectionView.reloadData()
        updatePlaceholderType()
    }
}

// MARK: TrackerViewCellDelegate

extension TrackersViewController: TrackerViewCellProtocol {
    func trackerDoneButtonDidSwitched(to isCompleted: Bool, for trackerID: UUID) {
        analytics?.report(event: .click, screen: .main, item: .track)
        dataProvider?.switchTracker(withID: trackerID, to: isCompleted, for: currentDate)
        // важно искать indexPath после switchTracker, т.к. switchTracker может изменить его
        // например, если наложен фильтр "Только незавершенные"
        guard let indexPath = dataProvider?.indexPath(for: trackerID),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerViewCell
        else { return }
        cell.isCompleted = isCompleted
        cell.quantity = dataProvider?.getCompletedRecordsForTracker(at: indexPath)
    }

    func pinTrackerDidTap(to isPinned: Bool, at indexPath: IndexPath) {
        dataProvider?.pinTracker(to: isPinned, at: indexPath)
    }

    func editTrackerDidTap(at indexPath: IndexPath) {
        analytics?.report(event: .click, screen: .main, item: .edit)
        guard let tracker = dataProvider?.object(at: indexPath) as? Tracker
        else { return }

        let viewController = CreateTrackerTypeSelectionViewController.createTrackerViewController(
            isRegular: tracker.isRegular,
            saverDelegate: self,
            dataProvider: dataProvider
        )
        viewController.tracker = tracker
        viewController.category = dataProvider?.getCategoryForTracker(at: indexPath)
        present(viewController, animated: true)
    }

    func deleteTrackerDidTap(at indexPath: IndexPath) {
        analytics?.report(event: .click, screen: .main, item: .delete)
        let alertController = UIAlertController(
            title: "trackersList.approveToDelete".localized(),
            message: nil,
            preferredStyle: .actionSheet
        )
        alertController.addAction(UIAlertAction(
            title: "trackersList.approveDeletion".localized(),
            style: .destructive
        ) { [weak self] _ in
            self?.dataProvider?.deleteTracker(at: indexPath)
        })
        alertController.addAction(UIAlertAction(
            title: "trackersList.cancelDeletion".localized(),
            style: .cancel
        ))
        present(alertController, animated: true)
    }
}

// MARK: Navigation bar delegate

extension TrackersViewController: TrackersBarControllerProtocol {
    func currentDateDidChange(for selectedDate: Date) {
        currentDate = selectedDate
        dataProvider?.setDateFilter(with: selectedDate)
        collectionView.reloadData()
        updatePlaceholderType()
        updateFilterButtonState()
    }

    func addTrackerButtonDidTapped() {
        analytics?.report(event: .click, screen: .main, item: .addTrack)
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
        dataProvider?.setSearchTextFilter(with: searchTextFilter)
        collectionView.reloadData()
        updatePlaceholderType()
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

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: TrackerViewCell.cellIdentifier,
                                for: indexPath) as? TrackerViewCell,
              let tracker = dataProvider?.object(at: indexPath) as? Tracker
        else {return UICollectionViewCell()}

        cell.delegate = self
        cell.isDoneButtonEnabled = !currentDate.isGreater(than: Date())
        cell.tracker = tracker
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(
            width: (collectionView.frame.width - params.paddingWidth) / CGFloat(params.cellCount),
            height: 90 + TrackerViewCell.quantityCardHeight
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: params.leftInset, bottom: 12, right: params.rightInset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
           let view = collectionView.dequeueReusableSupplementaryView(
                            ofKind: kind,
                            withReuseIdentifier: TrackersSectionHeaderView.viewIdentifier,
                            for: indexPath
                ) as? TrackersSectionHeaderView {
            if isPinnedSection(indexPath.section) {
                view.headerLabel.text = "trackersList.pinnedCategory".localized()
            } else {
                view.headerLabel.text = dataProvider?.getCategoryForTracker(at: indexPath)?.name ?? ""
            }
            return view
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if isPinnedSection(section) && dataProvider?.numberOfPinned == 0 {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: collectionView.frame.width, height: 18)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let tracker = dataProvider?.object(at: indexPath) as? Tracker
        else { return nil }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else { return UIMenu() }
            let pinActionTitle = tracker.isPinned ? "trackersList.unpin".localized() : "trackersList.pin".localized()
            let pinAction = UIAction(title: pinActionTitle) { [weak self] _ in
                guard let self else { return }
                self.pinTrackerDidTap(to: !tracker.isPinned, at: indexPath)
            }

            let editAction = UIAction(title: "trackersList.edit".localized()) { [weak self] _ in
                guard let self else { return }
                self.editTrackerDidTap(at: indexPath)
            }

            let deleteAction = UIAction(
                title: "trackersList.delete".localized(),
                attributes: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                self.deleteTrackerDidTap(at: indexPath)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerViewCell
        else { return nil }

        let preview = UITargetedPreview(view: cell.getTrackerView())

        return preview
    }
}

// MARK: TrackersDataProviderDelegate

extension TrackersViewController: TrackerDataProviderDelegate {
    func didUpdateIndexPath(_ updatedIndexes: UpdatedIndexes) {

        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: updatedIndexes.deletedIndexes)
            collectionView.insertItems(at: updatedIndexes.insertedIndexes)

            if !updatedIndexes.deletedSections.isEmpty {
                collectionView.deleteSections(updatedIndexes.deletedSections)
            }
            if !updatedIndexes.insertedSections.isEmpty {
                collectionView.insertSections(updatedIndexes.insertedSections)
            }
        },
        completion: { [weak self] finished in
            guard finished,
                  let self else { return }
            self.updatePlaceholderType()
            self.updateFilterButtonState()
        })
    }
}

// MARK: Layout

private extension TrackersViewController {

    func createSearchTextField() -> UISearchTextField {
        let searchField = UISearchTextField()
        searchField.placeholder = "trackersList.search".localized()
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
        collectionView.backgroundColor = .ypWhiteDay
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: TrackerViewCell.cellIdentifier)
        collectionView.register(TrackersSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackersSectionHeaderView.viewIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    func createFilterButton() -> RoundedButton {
        let button = RoundedButton(title: "trackersList.filter".localized())
        button.backgroundColor = .ypBlue
        button.titleLabel?.textColor = .ypWhiteDay
        button.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        return button
    }

    func addSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        addPlaceholder()
    }

    func updatePlaceholderType() {
        if let dataProvider,
           dataProvider.numberOfObjects != 0 {
            emptyCollectionPlaceholder.isHidden = true
        } else if searchTextFilter.isEmpty {
            emptyCollectionPlaceholder.isHidden = false
            emptyCollectionPlaceholder.placeholderType = .noData
        } else {
            emptyCollectionPlaceholder.isHidden = false
            emptyCollectionPlaceholder.placeholderType = .emptyList
        }
    }

    func addPlaceholder() {
        view.addSubview(emptyCollectionPlaceholder)
        emptyCollectionPlaceholder.isHidden = true
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
            emptyCollectionPlaceholder.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),

            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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

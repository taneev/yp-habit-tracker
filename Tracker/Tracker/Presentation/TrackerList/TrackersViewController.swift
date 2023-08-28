//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Тимур Танеев on 01.08.2023.
//

import UIKit
import CoreData

protocol TrackersBarControllerProtocol: AnyObject {
    func addTrackerButtonDidTapped()
    func currentDateDidChange(for selectedDate: Date)
}

protocol NewTrackerSaverDelegate: AnyObject {
    func save(tracker: TrackerCoreData, in category: TrackerCategoryCoreData)
}

final class TrackersViewController: UIViewController {

    private lazy var mainContext = { getMainContext() }()
    private lazy var fetchResultController = { initFetchResultController() }()

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

    private func getMainContext() -> NSManagedObjectContext?  {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer?.viewContext
    }

    private func initFetchResultController() -> NSFetchedResultsController<TrackerCoreData>? {
        guard let mainContext else {return nil}

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        if let predicate = createPredicateWith(selectedDate: Date(), searchString: "") {
            fetchRequest.predicate = predicate
        }
        let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: mainContext,
                sectionNameKeyPath: #keyPath(TrackerCoreData.category),
                cacheName: nil
        )
        controller.delegate = self
        return controller
    }


    @objc private func handleAnyTap(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }

    private func loadData() {
        MockDataGenerator.setupRecords(with: mainContext)
        try? fetchResultController?.performFetch()
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

    private func hasCompletedRecords(tracker: TrackerCoreData, for date: Date) -> Bool {
        guard let completedDates = tracker.completed as? Set<TrackerRecordCoreData>
        else {return false}

        return completedDates.first(where: { date.isEqual(to: $0.completedAt)}) != nil
    }

    private func completeTracker(tracker: TrackerCoreData, for date: Date) {
        guard let mainContext,
              let record = NSEntityDescription.insertNewObject(forEntityName: "TrackerRecordCoreData", into: mainContext) as? TrackerRecordCoreData
        else {return}

        record.completedAt = date
        record.tracker = tracker
        try? mainContext.save()
    }

    private func uncompleteTracker(tracker: TrackerCoreData, for date: Date) {
        guard let mainContext,
              let completed = tracker.completed as? Set<TrackerRecordCoreData>
        else {return}

        completed.forEach{ record in
            if date.isEqual(to: record.completedAt) {
                mainContext.delete(record)
            }
        }
        try? mainContext.save()
    }

    private func getCompletedTrackersCount(tracker: TrackerCoreData, for date: Date) -> Int {
        guard let completedDates = tracker.completed as? Set<TrackerRecordCoreData>
        else {return 0}

        let records: Set<TrackerRecordCoreData> = completedDates.filter{
            date.isGreater(than: $0.completedAt) || date.isEqual(to: $0.completedAt)
        }
        return records.count
    }

    private func createPredicateWith(selectedDate: Date, searchString: String? = nil) -> NSPredicate? {
        guard let currentWeekDay = WeekDay(rawValue: Calendar.current.component(.weekday, from: selectedDate))
        else {return nil}
        let weekDayText = WeekDay.shortWeekdayText[currentWeekDay] ?? ""

        let searchText = searchString?.trimmingCharacters(in: .whitespaces) ?? ""

        if searchText.isEmpty {
            return NSPredicate(
                        format: "%K == %@ OR %K CONTAINS[c] %@",
                        #keyPath(TrackerCoreData.isRegular),
                        NSNumber(booleanLiteral: false),
                        #keyPath(TrackerCoreData.schedule),
                        weekDayText
                   )
        }
        else {
            return NSPredicate(
                        format: "(%K == %@ OR %K CONTAINS[c] %@) AND %K CONTAINS[c] %@",
                        #keyPath(TrackerCoreData.isRegular),
                        NSNumber(booleanLiteral: false),
                        #keyPath(TrackerCoreData.schedule),
                        weekDayText,
                        #keyPath(TrackerCoreData.name),
                        searchText
                   )
        }
    }
}

extension TrackersViewController: NSFetchedResultsControllerDelegate {

}

extension TrackersViewController: NewTrackerSaverDelegate {
    func save(tracker: TrackerCoreData, in category: TrackerCategoryCoreData) {
        tracker.category = category
        try? mainContext?.save()
        try? fetchResultController?.performFetch()
        collectionView.reloadData()
        dismiss(animated: true)
    }
}

// MARK: TrackerViewCellDelegate
extension TrackersViewController: TrackerViewCellProtocol {
    func trackerDoneButtonDidTapped(for tracker: TrackerCoreData) {
        if hasCompletedRecords(tracker: tracker, for: currentDate) {
            uncompleteTracker(tracker: tracker, for: currentDate)
        }
        else {
            completeTracker(tracker: tracker, for: currentDate)
        }
    }

    func trackerCounterValue(for tracker: TrackerCoreData) -> Int {
        return getCompletedTrackersCount(tracker: tracker, for: currentDate)
    }
}

// MARK: Navigation bar delegate
extension TrackersViewController: TrackersBarControllerProtocol {
    func currentDateDidChange(for selectedDate: Date) {
        currentDate = selectedDate
        if let predicate = createPredicateWith(selectedDate: selectedDate, searchString: "") {
            fetchResultController?.fetchRequest.predicate = predicate
            try? fetchResultController?.performFetch()
            collectionView.reloadData()
        }
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
        searchTextFilter = textField.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        fetchResultController?.fetchRequest.predicate = createPredicateWith(selectedDate: currentDate, searchString: searchTextFilter)
        try? fetchResultController?.performFetch()
        collectionView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
    }
}

// MARK: UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchResultController?.sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController?.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.cellIdentifier, for: indexPath) as? TrackerViewCell,
              let tracker = fetchResultController?.object(at: indexPath) as? TrackerCoreData
        else {return UICollectionViewCell()}
     //   print("\(indexPath.section) \(tracker.category?.name): \(indexPath.row) \(tracker.name)")
        cell.delegate = self
        cell.tracker = tracker
        cell.isCompleted = hasCompletedRecords(tracker: tracker, for: currentDate)
        cell.quantity = getCompletedTrackersCount(tracker: tracker, for: currentDate)

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
           let view = collectionView.dequeueReusableSupplementaryView(
                            ofKind: kind,
                            withReuseIdentifier: TrackersSectionHeaderView.viewIdentifier,
                            for: indexPath
                ) as? TrackersSectionHeaderView {
            view.headerLabel.text = fetchResultController?.object(at: indexPath).category?.name
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

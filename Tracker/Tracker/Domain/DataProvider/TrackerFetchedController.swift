//
//  TrackerFetchedController.swift
//  Tracker
//
//  Created by Тимур Танеев on 16.09.2023.
//

import Foundation

protocol TrackerFetchedControllerDelegate: AnyObject {
    func didUpdate(_ updatedIndexes: UpdatedIndexes, isPinned: Bool)
}

protocol PinnedTrackerFetchedController: TrackerStoreFetchControllerProtocol {
    var numberOfPinned: Int { get }
}

final class TrackerFetchedController {
    private var dataProviderDelegate: DataProviderForCollectionLayoutDelegate
    private var fetchedUnpinnedController: (any TrackerStoreFetchControllerProtocol)?
    private var fetchedPinnedController: (any TrackerStoreFetchControllerProtocol)?

    init(
        dataStore: DataStoreProtocol,
        dataProviderDelegate: DataProviderForCollectionLayoutDelegate
    ) {
        self.dataProviderDelegate = dataProviderDelegate
        self.fetchedUnpinnedController = TrackerStoreFetchController(
            dataStore: dataStore,
            delegate: self,
            pinned: false
        )
        self.fetchedPinnedController = TrackerStoreFetchController(
            dataStore: dataStore,
            delegate: self,
            pinned: true
        )
    }
}

// MARK: TrackerStoreFetchControllerProtocol

extension TrackerFetchedController: TrackerStoreFetchControllerProtocol {
    typealias T = TrackerStore

    var numberOfObjects: Int? {
        let unpinnedTrackers = fetchedUnpinnedController?.numberOfObjects ?? 0
        let pinnedTrackers = fetchedPinnedController?.numberOfObjects ?? 0
        return pinnedTrackers + unpinnedTrackers
    }

    var numberOfSections: Int? {
        (fetchedUnpinnedController?.numberOfSections ?? 0) + 1
    }

    func numberOfRows(in section: Int) -> Int? {
        if section == 0 {
            return fetchedPinnedController?.numberOfRows(in: 0) ?? 0
        }
        else {
            return fetchedUnpinnedController?.numberOfRows(in: section - 1) ?? 0
        }
    }

    func object(at indexPath: IndexPath) -> TrackerStore? {
        if indexPath.section == 0 {
            return fetchedPinnedController?.object(at: indexPath) as? TrackerStore
        }
        else {
            let unpinnedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            return fetchedUnpinnedController?.object(at: unpinnedIndexPath)
        }
    }

    func fetchData() {
        fetchedPinnedController?.fetchData()
        fetchedUnpinnedController?.fetchData()
    }

    func updateFilterWith(selectedDate currentDate: Date, searchString searchTextFilter: String) {
        fetchedPinnedController?.updateFilterWith(selectedDate: currentDate, searchString: searchTextFilter)
        fetchedUnpinnedController?.updateFilterWith(selectedDate: currentDate, searchString: searchTextFilter)
    }

    func indexPath(for trackerID: UUID) -> IndexPath? {
        if let pinnedIndexPath = fetchedPinnedController?.indexPath(for: trackerID) {
            return pinnedIndexPath
        }
        else if let unpinnedIndexPath = fetchedUnpinnedController?.indexPath(for: trackerID) {
            let indexPath = IndexPath(row: unpinnedIndexPath.row, section: unpinnedIndexPath.section + 1)
            return indexPath
        }
        return nil
    }
}

extension TrackerFetchedController: PinnedTrackerFetchedController {
    var numberOfPinned: Int {
        fetchedPinnedController?.numberOfObjects ?? 0
    }
}

// MARK: TrackerFetchedControllerDelegate

extension TrackerFetchedController: TrackerFetchedControllerDelegate {
    func didUpdate(_ updatedIndexes: UpdatedIndexes, isPinned: Bool) {
        let sectionMap: (IndexSet.Element) -> IndexSet.Element = { isPinned ? 0 : $0 + 1 }
        let insertedSections = IndexSet(updatedIndexes.insertedSections.map(sectionMap))
        let deletedSections = IndexSet(updatedIndexes.deletedSections.map(sectionMap))

        let indexPathMap: (IndexPath) -> IndexPath = {
            isPinned ? IndexPath(row: $0.row, section: 0) : IndexPath(row: $0.row, section: $0.section + 1)
        }
        let insertedIndexes = updatedIndexes.insertedIndexes.map(indexPathMap)
        let deletedIndexes = updatedIndexes.deletedIndexes.map(indexPathMap)
        dataProviderDelegate.didUpdate(
            UpdatedIndexes(
                insertedSections: insertedSections,
                insertedIndexes: insertedIndexes,
                deletedSections: deletedSections,
                deletedIndexes: deletedIndexes
            )
        )
    }
}

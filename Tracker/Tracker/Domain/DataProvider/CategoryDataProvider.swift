//
//  DataProvider.swift
//  Tracker
//
//  Created by Тимур Танеев on 29.08.2023.
//
import UIKit

protocol CategoryDataProviderProtocol: AnyObject, DataProviderForDataSource, DataProviderForCollectionLayoutDelegate {
    var dataStore: DataStoreProtocol {get}
    var numberOfObjects: Int {get}
    func loadData()
    func getDefaultCategory() -> TrackerCategory?
    func save(category: TrackerCategory)
}

final class CategoryDataProvider {
    private weak var delegate: DataProviderDelegate?
    var dataStore: DataStoreProtocol
    private var fetchedController: (any DataStoreFetchedControllerProtocol)?

    init(delegate: DataProviderDelegate) {
        self.delegate = delegate
        self.dataStore = DataStore.shared
        self.fetchedController = CategoryStoreFetchController(
            dataStore: dataStore,
            dataProviderDelegate: self
        )
    }
}

extension CategoryDataProvider: DataProviderForDataSource {
    typealias T = TrackerCategory

    var numberOfSections: Int {
        fetchedController?.numberOfSections ?? 1
    }

    func numberOfRows(in section: Int) -> Int {
        fetchedController?.numberOfRows(in: section) ?? 0
    }

    func object(at indexPath: IndexPath) -> T? {
        guard let categoryStore = fetchedController?.object(at: indexPath) as? TrackerCategoryStore
        else {return nil}

        let category = T(id: categoryStore.categoryID, name: categoryStore.name)
        return category
    }
}

extension CategoryDataProvider: DataProviderForCollectionLayoutDelegate {
    func didUpdate(_ updatedIndexes: UpdatedIndexes) {
        delegate?.didUpdateIndexPath(updatedIndexes)
    }
}

extension CategoryDataProvider: CategoryDataProviderProtocol {
    var numberOfObjects: Int {
        fetchedController?.numberOfObjects ?? 0
    }

    func loadData() {
        fetchedController?.fetchData()
    }

    func getDefaultCategory() -> TrackerCategory? {
        guard let categoryStore = MockDataGenerator.getDefaultCategory(for: dataStore)
        else {return nil}

        return TrackerCategory(id: categoryStore.categoryID, name: categoryStore.name)
    }

    func save(category: TrackerCategory) {

        guard let context = dataStore.getContext() else {return}

        let categoryStore = TrackerCategoryStore(categoryID: category.categoryID, name: category.name)
        categoryStore.addRecord(context: context)
    }
}
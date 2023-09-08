//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import Foundation

struct CategoryListViewModelBindings {
    let numberOfCategories: (Int?) -> Void
    let isPlaceHolderHidden: (Bool?) -> Void
    let selectedRow: (IndexPath?) -> Void
    let selectedCategory: (TrackerCategory?) -> Void
}

protocol CategoryListViewModelProtocol: AnyObject {
    var dataProvider: any CategoryDataProviderProtocol {get}
    func viewDidLoad()
    func setBindings(_ bindings: CategoryListViewModelBindings)
    func didSelect(_ category: TrackerCategory?, at indexPath: IndexPath, isInitialSelection: Bool)
    func didDeselectRow(at indexPath: IndexPath)
    func addCellViewModel(at indexPath: IndexPath, cellViewModel: CategoryViewModelProtocol)
    func removeCellViewModel(at indexPath: IndexPath)
    func cellViewModel(forCellAt indexPath: IndexPath) -> CategoryViewModelProtocol
    func getSelectedCategory() -> TrackerCategory?
}

// MARK: CategoryListViewModel

final class CategoryListViewModel: CategoryListViewModelProtocol {
    var dataProvider: any CategoryDataProviderProtocol

    @Observable
    private var numberOfCategories: Int?

    @Observable
    private var isPlaceHolderHidden: Bool?

    @Observable
    private var selectedRow: IndexPath?

    @Observable
    private var selectedCategory: TrackerCategory?

    private var cellViewModels: [IndexPath: CategoryViewModelProtocol]

    init(dataProvider: any CategoryDataProviderProtocol, selectedCategory: TrackerCategory?) {
        self.dataProvider = dataProvider
        self.selectedCategory = selectedCategory
        self.cellViewModels = [:]
    }

    func viewDidLoad() {
        dataProvider.loadData()
        numberOfCategories = dataProvider.numberOfObjects
        isPlaceHolderHidden = (numberOfCategories ?? 0) > 0
    }

    func setBindings(_ bindings: CategoryListViewModelBindings) {
        self.$numberOfCategories.bind(action: bindings.numberOfCategories)
        self.$isPlaceHolderHidden.bind(action: bindings.isPlaceHolderHidden)
        self.$selectedRow.bind(action: bindings.selectedRow)
        self.$selectedCategory.bind(action: bindings.selectedCategory)
    }

    func didSelect(_ category: TrackerCategory?, at indexPath: IndexPath, isInitialSelection: Bool) {
        selectedRow = indexPath
        if !isInitialSelection {
            selectedCategory = category
        }
    }

    func didDeselectRow(at indexPath: IndexPath) {
        selectedRow = nil
        selectedCategory = nil
    }

    func addCellViewModel(at indexPath: IndexPath, cellViewModel: CategoryViewModelProtocol) {
        cellViewModels[indexPath] = cellViewModel
    }

    func removeCellViewModel(at indexPath: IndexPath) {
        cellViewModels.removeValue(forKey: indexPath)
    }

    func cellViewModel(forCellAt indexPath: IndexPath) -> CategoryViewModelProtocol {
        if let cellViewModel = cellViewModels[indexPath] {
            return cellViewModel
        }
        let newModel = CategoryViewModel(forCellAt: indexPath, listViewModel: self)
        addCellViewModel(at: indexPath, cellViewModel: newModel)
        return newModel
    }

    func getSelectedCategory() -> TrackerCategory? {
        return selectedCategory
    }
}

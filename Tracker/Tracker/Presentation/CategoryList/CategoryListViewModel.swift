//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import Foundation

struct CategoryListViewModelBindings {
    let isPlaceHolderHidden: (Bool?) -> Void
    let selectedRow: (IndexPath?) -> Void
    let selectedCategory: (TrackerCategory?) -> Void
    let editingCategory: (TrackerCategory?) -> Void
}

protocol SaveCategoryDelegate {
    func saveNewCategory(with name: String)
}

protocol CategoryListViewModelProtocol: AnyObject {
    var dataProvider: any CategoryDataProviderProtocol {get}
    var categoriesCount: Int {get}
    func viewDidLoad()
    func setBindings(_ bindings: CategoryListViewModelBindings)
    func didSelect(_ category: TrackerCategory?, at indexPath: IndexPath, isInitialSelection: Bool)
    func didDeselectRow(at indexPath: IndexPath)
    func addCellViewModel(at indexPath: IndexPath, cellViewModel: CategoryCellViewModelProtocol)
    func removeCellViewModel(at indexPath: IndexPath)
    func cellViewModel(forCellAt indexPath: IndexPath) -> CategoryCellViewModelProtocol
    func getSelectedCategory() -> TrackerCategory?
    func editCategoryDidTap(at indexPath: IndexPath)
    func deleteCategoryDidTap(at indexPath: IndexPath)
}

// MARK: CategoryListViewModel

final class CategoryListViewModel: CategoryListViewModelProtocol {
    var dataProvider: any CategoryDataProviderProtocol
    var categoriesCount: Int {
        dataProvider.numberOfObjects
    }

    @Observable
    private var isPlaceHolderHidden: Bool?

    @Observable
    private var selectedRow: IndexPath?

    @Observable
    private var selectedCategory: TrackerCategory?

    @Observable
    private var editingCategory: TrackerCategory?

    private var cellViewModels: [IndexPath: CategoryCellViewModelProtocol]

    init(dataProvider: any CategoryDataProviderProtocol, selectedCategory: TrackerCategory?) {
        self.dataProvider = dataProvider
        self.selectedCategory = selectedCategory
        self.cellViewModels = [:]
    }

    func viewDidLoad() {
        dataProvider.loadData()
        isPlaceHolderHidden = categoriesCount > 0
    }

    func setBindings(_ bindings: CategoryListViewModelBindings) {
        self.$isPlaceHolderHidden.bind(action: bindings.isPlaceHolderHidden)
        self.$selectedRow.bind(action: bindings.selectedRow)
        self.$selectedCategory.bind(action: bindings.selectedCategory)
        self.$editingCategory.bind(action: bindings.editingCategory)
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

    func addCellViewModel(at indexPath: IndexPath, cellViewModel: CategoryCellViewModelProtocol) {
        cellViewModels[indexPath] = cellViewModel
    }

    func removeCellViewModel(at indexPath: IndexPath) {
        cellViewModels.removeValue(forKey: indexPath)
    }

    func cellViewModel(forCellAt indexPath: IndexPath) -> CategoryCellViewModelProtocol {
        if let cellViewModel = cellViewModels[indexPath] {
            return cellViewModel
        }
        let newModel = CategoryCellViewModel(forCellAt: indexPath, listViewModel: self)
        addCellViewModel(at: indexPath, cellViewModel: newModel)
        return newModel
    }

    func getSelectedCategory() -> TrackerCategory? {
        return selectedCategory
    }

    func editCategoryDidTap(at indexPath: IndexPath) {
        guard let category = dataProvider.object(at: indexPath) as? TrackerCategory
        else {return}

        editingCategory = category
    }

    func deleteCategoryDidTap(at indexPath: IndexPath) {
        cellViewModels[indexPath]?.didDeselectRow()
        dataProvider.deleteCategory(at: indexPath)
        cellViewModels.removeValue(forKey: indexPath)
    }
}

extension CategoryListViewModel: SaveCategoryDelegate {
    func saveNewCategory(with name: String) {
        let category = TrackerCategory(id: UUID(), name: name)
        dataProvider.save(category: category)
    }
}

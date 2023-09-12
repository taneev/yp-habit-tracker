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
    let editingCategory: (TrackerCategory?) -> Void
}

protocol CategoryListViewModelProtocol: AnyObject {
    var dataProvider: any CategoryDataProviderProtocol { get }
    var categoriesCount: Int { get }
    func viewDidLoad()
    func setBindings(_ bindings: CategoryListViewModelBindings)
    func didSelectRow(at indexPath: IndexPath, isInitialSelection: Bool)
    func didDeselectRow(at indexPath: IndexPath)
    func updateViewModels(deleteAt deletedIndexes: [IndexPath], insertAt insertedIndexes: [IndexPath])
    func cellViewModel(forCellAt indexPath: IndexPath) -> CategoryCellViewModelProtocol
    func configCell(at indexPath: IndexPath)
    func editCategoryDidTap(at indexPath: IndexPath)
    func categoryEditingDidEnd()
    func deleteCategoryDidTap(at indexPath: IndexPath)
    func updateEditedCategory(_ category: TrackerCategory)
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
    private var editingCategory: TrackerCategory?

    private var selectionDelegate: CategorySelectionDelegate
    private var selectedCategory: TrackerCategory?
    private var cellViewModels: [CategoryCellViewModelProtocol]

    init(
        dataProvider: any CategoryDataProviderProtocol,
        selectedCategory: TrackerCategory?,
        selectionDelegate: CategorySelectionDelegate
    ) {
        self.dataProvider = dataProvider
        self.selectedCategory = selectedCategory
        self.cellViewModels = []
        self.selectionDelegate = selectionDelegate
    }

    func viewDidLoad() {
        dataProvider.loadData()
        isPlaceHolderHidden = categoriesCount > 0
    }

    func configCell(at indexPath: IndexPath) {
        guard let category = dataProvider.object(at: indexPath) as? TrackerCategory
        else { return }

        let isSelected = selectedCategory?.categoryID == category.categoryID
        cellViewModels[indexPath.item].setupModelWith(
            categoryName: category.name,
            isSelected: isSelected
        )

        if isSelected {
            selectedRow = indexPath
        }
    }

    func setBindings(_ bindings: CategoryListViewModelBindings) {
        self.$isPlaceHolderHidden.bind(action: bindings.isPlaceHolderHidden)
        self.$selectedRow.bind(action: bindings.selectedRow)
        self.$editingCategory.bind(action: bindings.editingCategory)
    }

    func didSelectRow(at indexPath: IndexPath, isInitialSelection: Bool) {
        selectedRow = indexPath
        cellViewModels[indexPath.item].didSelectRow()
        if !isInitialSelection {
            guard let category = dataProvider.object(at: indexPath) as? TrackerCategory
            else { return }
            selectionDelegate.updateSelected(category)
        }
    }

    func didDeselectRow(at indexPath: IndexPath) {
        cellViewModels[indexPath.item].didDeselectRow()
        selectedRow = nil
        selectedCategory = nil
    }

    func updateViewModels(deleteAt deletedIndexes: [IndexPath], insertAt insertedIndexes: [IndexPath]) {
        deletedIndexes.sorted(by: {$0.item > $1.item}).forEach{
            removeCellViewModel(at: $0)
        }
    }

    func cellViewModel(forCellAt indexPath: IndexPath) -> CategoryCellViewModelProtocol {
        return addCellViewModel(at: indexPath)
    }

    func editCategoryDidTap(at indexPath: IndexPath) {
        guard let category = dataProvider.object(at: indexPath) as? TrackerCategory
        else { return }

        editingCategory = category
    }

    func categoryEditingDidEnd() {
        editingCategory = nil
    }

    func updateEditedCategory(_ category: TrackerCategory) {
        dataProvider.save(category: category)
        if selectedCategory?.categoryID == category.categoryID {
            selectionDelegate.updateSelected(category)
        }
    }

    func deleteCategoryDidTap(at indexPath: IndexPath) {
        didDeselectRow(at: indexPath)
        selectionDelegate.updateSelected(nil)
        dataProvider.deleteCategory(at: indexPath)
    }

    private func addCellViewModel(at indexPath: IndexPath) -> CategoryCellViewModelProtocol {
        let newModel = CategoryCellViewModel()
        cellViewModels.insert(newModel, at: indexPath.item)
        return newModel
    }

    private func removeCellViewModel(at indexPath: IndexPath) {
        cellViewModels.remove(at: indexPath.item)
    }
}

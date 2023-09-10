//
//  CategoryCellViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 06.09.2023.
//

import Foundation

struct CategoryCellViewModelBindings {
    let categoryName: (String?) -> Void
    let isSelected: (Bool?) -> Void
}

protocol CategoryCellViewModelProtocol {
    func setBinidings(_ bindings: CategoryCellViewModelBindings)
    func cellViewDidLoad()
    func didSelectRow(isInitialSelection: Bool)
    func didDeselectRow()
}

final class CategoryCellViewModel: CategoryCellViewModelProtocol {

    @Observable
    private var categoryName: String?

    @Observable
    private var isSelected: Bool?

    private var category: TrackerCategory?
    private let indexPath: IndexPath
    private weak var listViewModel: CategoryListViewModelProtocol?

    init(forCellAt indexPath: IndexPath, listViewModel: CategoryListViewModelProtocol?) {
        self.indexPath = indexPath
        self.listViewModel = listViewModel
    }

    deinit {
        listViewModel?.removeCellViewModel(at: indexPath)
    }

    func setBinidings(_ bindings: CategoryCellViewModelBindings) {
        self.$categoryName.bind(action: bindings.categoryName)
        self.$isSelected.bind(action: bindings.isSelected)
    }

    func cellViewDidLoad() {
        guard let category = listViewModel?.dataProvider.object(at: indexPath) as? TrackerCategory
        else {return}
        categoryName = category.name
        self.category = category

        guard let selectedCategory = listViewModel?.getSelectedCategory() else {return}
        if category.categoryID == selectedCategory.categoryID {
            didSelectRow(isInitialSelection: true)
        }
    }

    func didSelectRow(isInitialSelection: Bool) {
        isSelected = true
        listViewModel?.didSelect(category, at: indexPath, isInitialSelection: isInitialSelection)
    }

    func didDeselectRow() {
        isSelected = false
        listViewModel?.didDeselectRow(at: indexPath)
    }
}

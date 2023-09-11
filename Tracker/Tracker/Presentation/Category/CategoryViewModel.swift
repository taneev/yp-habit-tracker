//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Тимур Танеев on 09.09.2023.
//

import Foundation

struct CategoryViewModelBindings {
    let isOkButtonEnabled: (Bool?) -> Void
    let isCategoryDidCreated: (Bool?) -> Void
}

enum CategoryMode {
    case new, edit
}

protocol CategoryViewModelProtocol {
    func setBindings(_ bindings: CategoryViewModelBindings)
    func viewDidLoad()
    func textFieldDidChange(to text: String?)
    func okButtonDidTap()
    func getInitialCategoryName() -> String
}

final class CategoryViewModel: CategoryViewModelProtocol {
    var saveCategory: ((TrackerCategory) -> Void)?

    @Observable
    private var isOkButtonEnabled: Bool?

    @Observable
    private var isCategoryDidCreated: Bool?

    private var categoryName: String?
    private var mode: CategoryMode
    private var category: TrackerCategory

    init(
        mode: CategoryMode,
        categoryToEdit: TrackerCategory? = nil
    ) {
        self.mode = mode
        self.category = categoryToEdit ?? TrackerCategory(id: UUID(), name: "")
    }

    func setBindings(_ bindings: CategoryViewModelBindings) {
        self.$isOkButtonEnabled.bind(action: bindings.isOkButtonEnabled)
        self.$isCategoryDidCreated.bind(action: bindings.isCategoryDidCreated)
    }

    func viewDidLoad() {
        isOkButtonEnabled = false
        textFieldDidChange(to: category.name)
    }

    func textFieldDidChange(to text: String?) {
        let normalizedName = normalized(categoryName: text)
        isOkButtonEnabled = !normalizedName.isEmpty
        categoryName = normalizedName
    }

    func okButtonDidTap() {
        guard let categoryName else {return}
        let updatedCategory = TrackerCategory(id: category.categoryID, name: categoryName)
        saveCategory?(updatedCategory)
        isCategoryDidCreated = true
    }

    private func normalized(categoryName text: String?) -> String {
        return text?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    func getInitialCategoryName() -> String {
        category.name
    }
}
